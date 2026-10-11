import unittest

import cartpole


def reference_step(observation, action):
    import math

    gravity = 9.8
    mass_cart = 1.0
    mass_pole = 0.1
    total_mass = mass_cart + mass_pole
    half_pole_length = 0.5
    pole_mass_length = mass_pole * half_pole_length
    force = 10.0 if action == 1 else -10.0
    time_step = 0.02

    x, x_velocity, theta, theta_velocity = observation
    cosine = math.cos(theta)
    sine = math.sin(theta)
    temporary = (force + pole_mass_length * theta_velocity**2 * sine) / total_mass
    theta_acceleration = (gravity * sine - cosine * temporary) / (
        half_pole_length * (4.0 / 3.0 - mass_pole * cosine**2 / total_mass)
    )
    x_acceleration = temporary - pole_mass_length * theta_acceleration * cosine / total_mass
    return (
        x + time_step * x_velocity,
        x_velocity + time_step * x_acceleration,
        theta + time_step * theta_velocity,
        theta_velocity + time_step * theta_acceleration,
    )


class CartPoleTests(unittest.TestCase):
    def test_reset_is_reproducible_and_returns_gymnasium_shape(self):
        environment = cartpole.CartPole()
        observation, info = environment.reset(seed=42)
        repeated_observation, repeated_info = environment.reset(seed=42)

        self.assertEqual(len(observation), 4)
        self.assertEqual(info, {})
        self.assertEqual(repeated_info, {})
        self.assertEqual(observation, repeated_observation)
        self.assertNotEqual(observation, environment.reset(seed=43)[0])

    def test_step_matches_classic_cartpole_euler_dynamics(self):
        environment = cartpole.CartPole()
        observation, _ = environment.reset(seed=123)
        expected_observation = reference_step(observation, action=1)

        result = environment.step(1)

        self.assertEqual(len(result), 5)
        actual_observation, reward, terminated, truncated, info = result
        for actual, expected in zip(actual_observation, expected_observation):
            self.assertAlmostEqual(actual, expected, places=14)
        self.assertEqual(reward, 1.0)
        self.assertFalse(terminated)
        self.assertFalse(truncated)
        self.assertEqual(info, {})

    def test_invalid_action_is_rejected(self):
        environment = cartpole.CartPole()
        environment.reset(seed=0)
        with self.assertRaisesRegex(ValueError, "action must be 0 or 1"):
            environment.step(2)

    def test_episode_truncates_at_cartpole_v1_limit(self):
        environment = cartpole.CartPole()
        observation, _ = environment.reset(seed=0)

        for _ in range(500):
            action = 0 if observation[2] + 0.5 * observation[3] < 0.0 else 1
            observation, _, terminated, truncated, _ = environment.step(action)
            if terminated or truncated:
                break

        self.assertFalse(terminated)
        self.assertTrue(truncated)

    def test_echo_observation_round_trips_values(self):
        environment = cartpole.CartPole()
        observation, _ = environment.reset(seed=9)
        self.assertEqual(environment.echo_observation(observation), observation)


if __name__ == "__main__":
    unittest.main()