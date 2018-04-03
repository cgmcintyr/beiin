#!/usr/bin/env python3

import matplotlib.pyplot as plt
import click
import logging
import os.path
import re
import sys
import time

from collections import defaultdict, namedtuple


BeiinOperationData = namedtuple('BeiinOperationData', ['time_sent', 'latency'])

FORMAT = '%(asctime)s - %(levelname)s - %(message)s'
OPERATION_REGEX = re.compile('(?P<operation>[A-Z]+)\s+(?P<time_sent>-?[\d]*)\s+(?P<latency>[\d]*)')
logger = logging.getLogger(__name__)

def plot_data_as_histogram(ax, operation, data):
    logger.info('Plotting hist {}'.format(operation))
    ax.hist(data, 100, facecolor='green', alpha=0.75, range=(0, 100000), density=True)
    ax.set_title(operation)
    ax.set(xlabel='Time (ms)', ylabel='Frequency')

def plot_data_as_scatter(ax, operation, x, y):
    logger.info('Plotting line {}'.format(operation))
    ax.scatter(x, y, s=10)
    ax.set_title(operation)
    ax.set(xlabel='Time (ms)', ylabel='Frequency')

def plot_latencies(latencies):
    logger.info('Plotting data')
    S = len(latencies)

    fig, axes = plt.subplots(S, ncols=1, sharex=True, sharey=True)
    #fig.text(0.06, 0.5, 'common ylabel', ha='center', va='center', rotation='vertical')

    if S == 1:
        operation, data = latencies.popitem()
        plot_data_as_histogram(axes, operation, data)
    else:
        current_ax = 0
        for operation, data in latencies.items():
            plot_data_as_histogram(axes[current_ax], operation, data)
            current_ax += 1

    fig.tight_layout()
    return fig

def plot_all(results):
    logger.info('Plotting data')
    S = len(results)

    fig, axes = plt.subplots(S, ncols=1, sharex=True, sharey=True)
    #fig.text(0.06, 0.5, 'common ylabel', ha='center', va='center', rotation='vertical')

    if S == 1:
        operation, data = results.popitem()
        plot_data_as_scatter(axes, operation, *zip(*data))
    else:
        current_ax = 0
        for operation, data in results.items():
            plot_data_as_scatter(axes[current_ax], operation, *zip(*data))
            current_ax += 1

    fig.tight_layout()
    return fig

@click.command()
@click.option('--verbose', '-v', is_flag=True, help='Print verbose messages.')
@click.argument('filename', type=click.Path(exists=True))
@click.argument('outfile', type=click.Path(writable=True))
def analyze(filename, outfile, verbose):

    if verbose:
        logging.basicConfig(level=logging.INFO, format=FORMAT)
    else:
        logging.basicConfig(level=logging.WARNING, format=FORMAT)
    logger.info('Running graph.py')

    results = defaultdict(list)

    with open(filename, 'r') as f:
        for line in f.readlines():
           match = OPERATION_REGEX.match(line.strip())
           if not match:
               continue

           operation = match.group('operation')
           time_sent = int(match.group('time_sent'))
           latency = int(match.group('latency'))
           results[operation].append(BeiinOperationData(time_sent, latency))


    fig = plot_latencies(latencies = {k: list(zip(*v)) for (k, v) in results.items()})
    fig.savefig(outfile)

    fig = plot_all(results)
    fig.savefig('all' + outfile)

if __name__ == '__main__':
    analyze()
