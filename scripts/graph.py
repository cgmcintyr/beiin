#!/usr/bin/env python3

import matplotlib.pyplot as plt
import click
import logging
import os.path
import re
import sys
import time

from collections import defaultdict

FORMAT = '%(asctime)s - %(levelname)s - %(message)s'
logger = logging.getLogger(__name__)

OPERATION_REGEX = re.compile('(?P<operation>[A-Z]+)\s+(?P<latency>[\d]*)')

def plot_data_as_histogram(ax, operation, data):
    logger.info('Plotting {}'.format(operation))
    ax.hist(data, 100, facecolor='green', alpha=0.75, range=(0, 100000))
    ax.set_title(operation)
    ax.set(xlabel='Time (ms)', ylabel='Frequency')

def plot_latencies(latencies):
    logger.info('Plotting data')
    S = len(latencies)

    fig, axes = plt.subplots(S, ncols=1, sharex=True, sharey=True)
    #fig.text(0.5, 0.04, 'common xlabel', ha='center', va='center')
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

    latencies = defaultdict(list)

    with open(filename, 'r') as f:
        for line in f.readlines():
           match = OPERATION_REGEX.match(line.strip())
           operation = match.group('operation')
           latency = int(match.group('latency'))
           latencies[operation].append(latency)

    fig = plot_latencies(latencies)
    fig.savefig(outfile)

if __name__ == '__main__':
    analyze()
