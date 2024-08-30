#!/usr/bin/env node
import { program } from 'commander';
import generate from './commands/generate/generate.js';

program
    .version('0.0.1');

program.command('generate')
    .description('Generate a set of Kubernetes CRDs from a CALM architecture document')
    .argument('<document>', 'CALM document file path to generate from')
    .argument('<config>', 'Pattern config file to use when generating')
    .option('-v, --verbose', 'Whether to do verbose level logging', false)
    .action(async (document, patternConfig, options) => {
        const output = await generate(document, patternConfig, options.verbose); 
        console.log(output);
    });

program.parse();