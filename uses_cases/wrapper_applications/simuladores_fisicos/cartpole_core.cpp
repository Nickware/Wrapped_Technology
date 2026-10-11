#include "cartpole_core.h"

#include <cmath>
#include <stdexcept>

namespace simuladores {
namespace {

const double gravity = 9.8;
const double mass_cart = 1.0;
const double mass_pole = 0.1;
const double total_mass = mass_cart + mass_pole;
const double half_pole_length = 0.5;
const double pole_mass_length = mass_pole * half_pole_length;
const double force_magnitude = 10.0;
const double time_step = 0.02;
const double cart_threshold = 2.4;
const double pole_threshold = 12.0 * 2.0 * std::acos(0.0) / 360.0;
const double two_to_the_53 = 9007199254740992.0;

}  // namespace

CartPole::CartPole()
    : state_{{0.0, 0.0, 0.0, 0.0}},
      random_state_(0),
      elapsed_steps_(0),
      has_reset_(false),
      episode_done_(false) {}

std::array<double, 4> CartPole::reset(std::uint64_t seed) {
    random_state_ = seed;
    for (double& value : state_) {
        value = uniform_initial_state_value();
    }
    elapsed_steps_ = 0;
    has_reset_ = true;
    episode_done_ = false;
    return state_;
}

StepResult CartPole::step(int action) {
    if (!has_reset_) {
        throw std::logic_error("reset(seed) must be called before step(action)");
    }
    if (episode_done_) {
        throw std::logic_error("episode is finished; call reset(seed) before stepping again");
    }
    if (action != 0 && action != 1) {
        throw std::invalid_argument("action must be 0 or 1");
    }

    const double x = state_[0];
    const double x_velocity = state_[1];
    const double theta = state_[2];
    const double theta_velocity = state_[3];
    const double force = action == 1 ? force_magnitude : -force_magnitude;
    const double cosine = std::cos(theta);
    const double sine = std::sin(theta);
    const double temporary =
        (force + pole_mass_length * theta_velocity * theta_velocity * sine) /
        total_mass;
    const double theta_acceleration =
        (gravity * sine - cosine * temporary) /
        (half_pole_length *
         (4.0 / 3.0 - mass_pole * cosine * cosine / total_mass));
    const double x_acceleration =
        temporary - pole_mass_length * theta_acceleration * cosine / total_mass;

    state_[0] = x + time_step * x_velocity;
    state_[1] = x_velocity + time_step * x_acceleration;
    state_[2] = theta + time_step * theta_velocity;
    state_[3] = theta_velocity + time_step * theta_acceleration;
    ++elapsed_steps_;

    const bool terminated =
        state_[0] < -cart_threshold || state_[0] > cart_threshold ||
        state_[2] < -pole_threshold || state_[2] > pole_threshold;
    const bool truncated = elapsed_steps_ >= max_episode_steps;
    episode_done_ = terminated || truncated;

    return StepResult{state_, 1.0, terminated, truncated};
}

std::uint64_t CartPole::next_random() {
    random_state_ += 0x9e3779b97f4a7c15ULL;
    std::uint64_t value = random_state_;
    value = (value ^ (value >> 30)) * 0xbf58476d1ce4e5b9ULL;
    value = (value ^ (value >> 27)) * 0x94d049bb133111ebULL;
    return value ^ (value >> 31);
}

double CartPole::uniform_initial_state_value() {
    const double unit_value = static_cast<double>(next_random() >> 11) / two_to_the_53;
    return -0.05 + 0.1 * unit_value;
}

}  // namespace simuladores