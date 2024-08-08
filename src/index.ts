#!/usr/bin/env node
import { program } from 'commander';
import generate from './commands/generate/generate.js';

program
    .version('0.0.1');

program.command('generate')
    .description('Generate a set of Kubernetes CRDs from a CALM architecture document')
    .argument('<document>', 'CALM document file path to generate from')
    .option('-v, --verbose', 'Whether to do verbose level logging', false)
    .action(async (arg, options) => {
        await generate(arg, options.verbose); 
    });

program.parse();