#!/usr/bin/env python3
"""Measure the Python/pybind11 boundary for a CartPole-like environment."""

import argparse
import csv
import importlib
import struct
import time
from pathlib import Path


def percentile(samples, fraction):
    if not samples:
        return 0.0
    ordered = sorted(samples)
    position = (len(ordered) - 1) * fraction
    lower = int(position)
    upper = min(lower + 1, len(ordered) - 1)
    weight = position - lower
    return ordered[lower] * (1.0 - weight) + ordered[upper] * weight


def payload_size_bytes(value):
    """Estimate numeric payload size, not Python object or binding overhead."""
    if hasattr(value, "nbytes"):
        return int(value.nbytes)
    if isinstance(value, memoryview):
        return value.nbytes
    if isinstance(value, (tuple, list)):
        return sum(payload_size_bytes(item) for item in value)
    if isinstance(value, bool):
        return struct.calcsize("?")
    if isinstance(value, int):
        return struct.calcsize("i")
    if isinstance(value, float):
        return struct.calcsize("d")
    if isinstance(value, (bytes, bytearray)):
        return len(value)
    if isinstance(value, str):
        return len(value.encode("utf-8"))
    raise TypeError(f"Unsupported payload type: {type(value).__name__}")


def choose_action(observation):
    """A deterministic CartPole policy; policy time is outside step timing."""
    return 0 if observation[2] < 0.0 else 1


def run_episodes(env, episode_count, max_steps, seed, collect):
    step_times_ns = []
    reset_times_ns = []
    action_payload_bytes = 0
    result_payload_bytes = 0
    steps = 0
    last_observation = None

    for episode_index in range(episode_count):
        reset_start = time.perf_counter_ns() if collect else 0
        reset_result = env.reset(seed=seed + episode_index)
        if collect:
            reset_times_ns.append(time.perf_counter_ns() - reset_start)
        observation = reset_result[0] if isinstance(reset_result, tuple) else reset_result

        for _ in range(max_steps):
            action = choose_action(observation)
            if collect:
                action_payload_bytes += payload_size_bytes(action)
                step_start = time.perf_counter_ns()

            result = env.step(action)
            steps += 1
            if collect:
                step_times_ns.append(time.perf_counter_ns() - step_start)

            if len(result) != 5:
                raise ValueError("step(action) must return the Gymnasium five-value result")
            observation, reward, terminated, truncated, _info = result
            if collect:
                result_payload_bytes += payload_size_bytes(observation)
                result_payload_bytes += payload_size_bytes(reward)
                result_payload_bytes += payload_size_bytes(terminated)
                result_payload_bytes += payload_size_bytes(truncated)
            last_observation = observation
            if terminated or truncated:
                break

    return {
        "steps": steps,
        "step_times_ns": step_times_ns,
        "reset_times_ns": reset_times_ns,
        "action_payload_bytes": action_payload_bytes,
        "result_payload_bytes": result_payload_bytes,
        "last_observation": last_observation,
    }


def measure_transfer_probe(env, observation, probe_count):
    echo = getattr(env, "echo_observation", None)
    if echo is None or observation is None or probe_count <= 0:
        return 0, 0, 0

    samples_ns = []
    for _ in range(probe_count):
        start = time.perf_counter_ns()
        echo(observation)
        samples_ns.append(time.perf_counter_ns() - start)
    return (
        percentile(samples_ns, 0.50),
        percentile(samples_ns, 0.95),
        payload_size_bytes(observation),
    )


def run_repeat(env_type, args, repeat_index):
    env = env_type()
    warmup_seed = args.seed + repeat_index * (args.episodes + args.warmup_episodes + 1)
    run_episodes(env, args.warmup_episodes, args.max_steps, warmup_seed, collect=False)

    measured_seed = warmup_seed + args.warmup_episodes
    latency_result = run_episodes(
        env, args.episodes, args.max_steps, measured_seed, collect=True
    )

    start = time.perf_counter_ns()
    throughput_result = run_episodes(
        env, args.episodes, args.max_steps, measured_seed, collect=False
    )
    elapsed_ns = time.perf_counter_ns() - start

    transfer_p50_ns, transfer_p95_ns, transfer_bytes = measure_transfer_probe(
        env, latency_result["last_observation"], args.transfer_probes
    )
    close = getattr(env, "close", None)
    if close is not None:
        close()

    step_count = throughput_result["steps"]
    latency_step_count = latency_result["steps"]
    elapsed_seconds = elapsed_ns / 1_000_000_000
    return {
        "variant": "pybind11_step",
        "repeat": repeat_index + 1,
        "seed": measured_seed,
        "episodes": args.episodes,
        "steps": step_count,
        "max_steps_per_episode": args.max_steps,
        "elapsed_seconds": elapsed_seconds,
        "steps_per_second": step_count / elapsed_seconds if elapsed_seconds else 0.0,
        "episodes_per_second": args.episodes / elapsed_seconds if elapsed_seconds else 0.0,
        "step_p50_ns": percentile(latency_result["step_times_ns"], 0.50),
        "step_p95_ns": percentile(latency_result["step_times_ns"], 0.95),
        "reset_p50_ns": percentile(latency_result["reset_times_ns"], 0.50),
        "action_payload_bytes_per_step_estimate": (
            latency_result["action_payload_bytes"] / latency_step_count
            if latency_step_count
            else 0.0
        ),
        "result_payload_bytes_per_step_estimate": (
            latency_result["result_payload_bytes"] / latency_step_count
            if latency_step_count
            else 0.0
        ),
        "echo_p50_ns": transfer_p50_ns,
        "echo_p95_ns": transfer_p95_ns,
        "echo_payload_bytes": transfer_bytes,
    }


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--module", default="cartpole", help="Python module built with pybind11")
    parser.add_argument("--class-name", default="CartPole", help="Environment class in the module")
    parser.add_argument("--episodes", type=int, default=100)
    parser.add_argument("--max-steps", type=int, default=500)
    parser.add_argument("--warmup-episodes", type=int, default=5)
    parser.add_argument("--repeats", type=int, default=5)
    parser.add_argument("--seed", type=int, default=1234)
    parser.add_argument("--transfer-probes", type=int, default=1000)
    parser.add_argument("--output", type=Path, default=Path("simulator_benchmark.csv"))
    return parser.parse_args()


def main():
    args = parse_args()
    if min(args.episodes, args.max_steps, args.repeats) <= 0:
        raise SystemExit("episodes, max-steps y repeats deben ser mayores que cero")
    if args.warmup_episodes < 0 or args.transfer_probes < 0:
        raise SystemExit("warmup-episodes y transfer-probes no pueden ser negativos")

    try:
        module = importlib.import_module(args.module)
        env_type = getattr(module, args.class_name)
    except (ImportError, AttributeError) as error:
        raise SystemExit(
            f"No se pudo cargar {args.class_name} desde {args.module}. "
            "Compila primero el módulo pybind11 y verifica que esté en PYTHONPATH."
        ) from error

    rows = [run_repeat(env_type, args, repeat) for repeat in range(args.repeats)]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = list(rows[0])
    with args.output.open("w", newline="", encoding="utf-8") as output_file:
        writer = csv.DictWriter(output_file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Benchmark: {args.module}.{args.class_name} ({args.repeats} repeticiones)")
    print(f"Resultados: {args.output}")
    print("La inferencia de la política no se incluye en la latencia step_p50/p95.")
    if args.transfer_probes:
        print("echo_p50/p95 solo se mide si el binding expone echo_observation().")


if __name__ == "__main__":
    main()
