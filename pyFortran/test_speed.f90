!! Program to measure the speed of a simple computation in Fortran
! test_speed.f90  

!! This program calculates the square root of the sum of squares of three numbers
! and measures the time taken for the computation.
! It calculates the square root of the sum of squares of three numbers
! in a nested loop and measures the time taken for the computation.
! It performs the calculation in a loop to simulate a more substantial workload.
! Use the command `gfortran -o test_speed test_speed.f90` to compile
! and then run with `./test_speed`.
! To run this program, ensure you have a Fortran compiler installed.

!! The program is written in Fortran and can be compiled with a Fortran compiler.
! The program is designed to be simple and straightforward for testing purposes.
! The program is intended to be run in a terminal or command line environment.
! This program is designed to test the speed of a simple computation in Fortran.

!! The program uses the `cpu_time` intrinsic to measure elapsed time.
! The result is printed to the console.

program test_speed
  real :: start, finish, r, x, y, z
  integer :: i, j
  call cpu_time(start)
  x = 1.0
  y = 2.0
  z = 3.0
  do j = 1, 3000
    do i = 1, 1000000
      r = sqrt(x*x + y*y + z*z)
    end do
  end do
  call cpu_time(finish)
  print *, 'Elapsed time = ', finish - start, ' seconds'
end program test_speed