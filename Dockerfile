# The MIT License
#
#  Copyright (c) 2016-2018, Oleg Nenashev, Stefan Wallentowitz
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

FROM ubuntu:16.04
MAINTAINER Oleg Nenashev <o.v.nenashev@gmail.com>
MAINTAINER Stefan Wallentowitz <stefan@wallentowitz.de>
LABEL Description="This is the default LibreCores CI Image" Vendor="Librecores" Version="2018.1-rc1"

USER root

ARG MAKE_JOBS=-j1

# Package Managers
ARG FUSESOC_VERSION=1.8

# Simulation
ARG ICARUS_VERILOG_VERSION=10_2
ARG VERILATOR_VERSION=3.920

# Synthesis
ARG YOSYS_VERSION=0.7

# Testing
ARG COCOTB_VERSION=561511a
ARG PYTEST_VERSION=3.4.2
ARG TAPPY_VERSION=2.2

# Cross-Compilers
ARG RISCV_VERSION=20171231
ARG OPENRISC_VERSION=2.4.0

RUN apt-get update && apt-get install -y \
    python2.7-dev libyaml-dev libyaml-dev python-pip python-yaml git libelf-dev \
    autoconf gperf bison flex build-essential clang libreadline-dev gawk tcl-dev \
    libffi-dev mercurial graphviz xdot pkg-config python3 virtualenv python3-venv \
    python3-dev openjdk-8-jre wget

RUN pip install --upgrade pip

# FuseSoC
ENV FUSESOC_VERSION=${FUSESOC_VERSION}
RUN pip install fusesoc==${FUSESOC_VERSION}

# Icarus Verilog
ENV ICARUS_VERILOG_VERSION=${ICARUS_VERILOG_VERSION}

WORKDIR /usr/src/iverilog
RUN git clone https://github.com/steveicarus/iverilog.git .
RUN git checkout v${ICARUS_VERILOG_VERSION}
RUN sh autoconf.sh
RUN ./configure
RUN make ${MAKE_JOBS}
RUN make install
RUN rm -r /usr/src/iverilog

# Verilator
ENV VERILATOR_VERSION=${VERILATOR_VERSION}

WORKDIR /usr/src/verilator
RUN git clone http://git.veripool.org/git/verilator .
RUN git checkout verilator_`echo "${VERILATOR_VERSION}" | tr '.' '_'`
RUN autoconf
RUN ./configure
RUN make ${MAKE_JOBS}
RUN make install
RUN rm -r /usr/src/verilator

# Yosys
WORKDIR /usr/src/yosys
RUN git clone http://github.com/cliffordwolf/yosys.git .
RUN git checkout yosys-${YOSYS_VERSION}
RUN make config-gcc
RUN make ${MAKE_JOBS}
RUN make install
RUN rm -r /usr/src/yosys

# Cocotb
RUN git clone https://github.com/potentialventures/cocotb.git
WORKDIR cocotb
RUN git checkout ${COCOTB_VERSION}
WORKDIR /tmp
ENV COCOTB=/tmp/cocotb

# pytest, nose and tappy
RUN pip install pytest==${PYTEST_VERSION}
RUN pip install tap.py==${TAPPY_VERSION}

# Cross-compilers
# RISC-V
WORKDIR /tmp
RUN wget https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-${RISCV_VERSION}-x86_64-linux-centos6.tar.gz
RUN tar -xzf riscv64-unknown-elf-gcc-${RISCV_VERSION}-x86_64-linux-centos6.tar.gz -C /opt
RUN rm riscv64-unknown-elf-gcc-${RISCV_VERSION}-x86_64-linux-centos6.tar.gz
ENV PATH="/opt/riscv64-unknown-elf-gcc-${RISCV_VERSION}-x86_64-linux-centos6/bin:${PATH}"

# OpenRISC
RUN wget https://github.com/openrisc/newlib/releases/download/v${OPENRISC_VERSION}/or1k-elf-multicore_gcc5.3.0_binutils2.26_newlib${OPENRISC_VERSION}_gdb7.11.tgz
RUN tar -xzf or1k-elf-multicore_gcc5.3.0_binutils2.26_newlib${OPENRISC_VERSION}_gdb7.11.tgz -C /opt
RUN rm or1k-elf-multicore_gcc5.3.0_binutils2.26_newlib${OPENRISC_VERSION}_gdb7.11.tgz
ENV PATH="/opt/or1k-elf-multicore/bin:${PATH}"