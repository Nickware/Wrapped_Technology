#pragma once

#include <array>
#include <cstdint>

namespace simuladores {

struct StepResult {
    std::array<double, 4> observation;
    double reward;
    bool terminated;
    bool truncated;
};

class CartPole {
public:
    static const int max_episode_steps = 500;

    CartPole();

    std::array<double, 4> reset(std::uint64_t seed);
    StepResult step(int action);

private:
    std::uint64_t next_random();
    double uniform_initial_state_value();

    std::array<double, 4> state_;
    std::uint64_t random_state_;
    int elapsed_steps_;
    bool has_reset_;
    bool episode_done_;
};

}  // namespace simuladores