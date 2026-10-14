#!/bin/bash
#Author:	Sebastian Uscategui
#Date:		05/05/2017
#version:	0.0.1

echo "Programa para dividir dos numeros"
read -p "Ingrese el primer valor a dividir " a
read -p "Ingrese el segundo valor a dividir " b
echo $a/$b | bc -l
#echo $c | bc -l

