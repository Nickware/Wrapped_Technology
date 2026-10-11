#include "cartpole_core.h"

#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

namespace py = pybind11;

PYBIND11_MODULE(cartpole, module) {
    py::class_<simuladores::CartPole>(module, "CartPole")
        .def(py::init<>())
        .def(
            "reset",
            [](simuladores::CartPole& environment, std::uint64_t seed) {
                return py::make_tuple(environment.reset(seed), py::dict());
            },
            py::arg("seed") = 0)
        .def(
            "step",
            [](simuladores::CartPole& environment, int action) {
                const simuladores::StepResult result = environment.step(action);
                return py::make_tuple(
                    result.observation,
                    result.reward,
                    result.terminated,
                    result.truncated,
                    py::dict());
            })
        .def("close", [](simuladores::CartPole&) {})
        .def("echo_observation", [](simuladores::CartPole&, const std::array<double, 4>& observation) {
            return observation;
        });
}