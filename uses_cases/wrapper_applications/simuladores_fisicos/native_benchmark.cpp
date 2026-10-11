#include "cartpole_core.h"

#include <algorithm>
#include <chrono>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

using Clock = std::chrono::steady_clock;

struct Options {
    int episodes = 100;
    int max_steps = 500;
    int warmup_episodes = 5;
    int repeats = 5;
    std::uint64_t seed = 1234;
    std::string output = "build/native_benchmark.csv";
};

struct RunResult {
    std::uint64_t steps = 0;
    std::vector<double> step_times_ns;
    std::vector<double> reset_times_ns;
};

double percentile(std::vector<double> samples, double fraction) {
    if (samples.empty()) {
        return 0.0;
    }
    std::sort(samples.begin(), samples.end());
    const double position = (samples.size() - 1) * fraction;
    const std::size_t lower = static_cast<std::size_t>(position);
    const std::size_t upper = std::min(lower + 1, samples.size() - 1);
    const double weight = position - lower;
    return samples[lower] * (1.0 - weight) + samples[upper] * weight;
}

int choose_action(const std::array<double, 4>& observation) {
    return observation[2] < 0.0 ? 0 : 1;
}

RunResult run_episodes(
    simuladores::CartPole& environment,
    int episode_count,
    int max_steps,
    std::uint64_t seed,
    bool collect) {
    RunResult result;
    for (int episode = 0; episode < episode_count; ++episode) {
        const std::uint64_t episode_seed = seed + static_cast<std::uint64_t>(episode);
        const auto reset_start = Clock::now();
        std::array<double, 4> observation = environment.reset(episode_seed);
        if (collect) {
            result.reset_times_ns.push_back(
                std::chrono::duration<double, std::nano>(Clock::now() - reset_start).count());
        }

        for (int step = 0; step < max_steps; ++step) {
            const int action = choose_action(observation);
            const auto step_start = Clock::now();
            const simuladores::StepResult step_result = environment.step(action);
            if (collect) {
                result.step_times_ns.push_back(
                    std::chrono::duration<double, std::nano>(Clock::now() - step_start).count());
            }
            ++result.steps;
            observation = step_result.observation;
            if (step_result.terminated || step_result.truncated) {
                break;
            }
        }
    }
    return result;
}

int parse_integer(const std::string& value, const std::string& option) {
    std::size_t parsed = 0;
    const int result = std::stoi(value, &parsed);
    if (parsed != value.size()) {
        throw std::invalid_argument("invalid value for " + option + ": " + value);
    }
    return result;
}

Options parse_options(int argc, char** argv) {
    Options options;
    for (int index = 1; index < argc; ++index) {
        const std::string option = argv[index];
        if (option == "--help") {
            std::cout << "Usage: native_benchmark [--episodes N] [--max-steps N] "
                         "[--warmup-episodes N] [--repeats N] [--seed N] [--output PATH]\n";
            std::exit(0);
        }
        if (index + 1 >= argc) {
            throw std::invalid_argument("missing value for " + option);
        }
        const std::string value = argv[++index];
        if (option == "--episodes") {
            options.episodes = parse_integer(value, option);
        } else if (option == "--max-steps") {
            options.max_steps = parse_integer(value, option);
        } else if (option == "--warmup-episodes") {
            options.warmup_episodes = parse_integer(value, option);
        } else if (option == "--repeats") {
            options.repeats = parse_integer(value, option);
        } else if (option == "--seed") {
            options.seed = std::stoull(value);
        } else if (option == "--output") {
            options.output = value;
        } else {
            throw std::invalid_argument("unknown option: " + option);
        }
    }
    if (options.episodes <= 0 || options.max_steps <= 0 || options.repeats <= 0 ||
        options.warmup_episodes < 0) {
        throw std::invalid_argument("episode, step, and repeat counts are invalid");
    }
    return options;
}

}  // namespace

int main(int argc, char** argv) {
    try {
        const Options options = parse_options(argc, argv);
        const std::filesystem::path output_path(options.output);
        if (!output_path.parent_path().empty()) {
            std::filesystem::create_directories(output_path.parent_path());
        }
        std::ofstream output(output_path);
        if (!output) {
            throw std::runtime_error("could not open output file: " + options.output);
        }

        output << "variant,repeat,seed,episodes,steps,max_steps_per_episode,elapsed_seconds,"
                  "steps_per_second,episodes_per_second,step_p50_ns,step_p95_ns,reset_p50_ns,"
                  "action_payload_bytes_per_step_estimate,result_payload_bytes_per_step_estimate,"
                  "echo_p50_ns,echo_p95_ns,echo_payload_bytes\n";

        for (int repeat = 0; repeat < options.repeats; ++repeat) {
            simuladores::CartPole environment;
            const std::uint64_t warmup_seed = options.seed + static_cast<std::uint64_t>(repeat) *
                static_cast<std::uint64_t>(options.episodes + options.warmup_episodes + 1);
            run_episodes(environment, options.warmup_episodes, options.max_steps, warmup_seed, false);
            const std::uint64_t measured_seed =
                warmup_seed + static_cast<std::uint64_t>(options.warmup_episodes);

            const RunResult latency = run_episodes(
                environment, options.episodes, options.max_steps, measured_seed, true);
            const auto throughput_start = Clock::now();
            const RunResult throughput = run_episodes(
                environment, options.episodes, options.max_steps, measured_seed, false);
            const double elapsed_seconds =
                std::chrono::duration<double>(Clock::now() - throughput_start).count();
            const double steps_per_second =
                elapsed_seconds == 0.0 ? 0.0 : throughput.steps / elapsed_seconds;
            const double episodes_per_second =
                elapsed_seconds == 0.0 ? 0.0 : options.episodes / elapsed_seconds;

            output << "native_cpp," << repeat + 1 << ',' << measured_seed << ','
                   << options.episodes << ',' << throughput.steps << ',' << options.max_steps << ','
                   << elapsed_seconds << ',' << steps_per_second << ',' << episodes_per_second << ','
                   << percentile(latency.step_times_ns, 0.50) << ','
                   << percentile(latency.step_times_ns, 0.95) << ','
                   << percentile(latency.reset_times_ns, 0.50) << ",,,,,\n";
        }

        std::cout << "Native benchmark: " << options.repeats << " repeticiones\n"
                  << "Resultados: " << output_path.string() << '\n';
    } catch (const std::exception& error) {
        std::cerr << "Error: " << error.what() << '\n';
        return 2;
    }
    return 0;
}