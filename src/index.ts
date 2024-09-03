#!/usr/bin/env node
import { program } from 'commander';
import generate from './commands/generate/generate.js';
import * as fs from 'node:fs/promises'
import * as path from 'node:path';

program
    .version('0.1.0');

program.command('generate')
    .description('Generate a set of Kubernetes CRDs from a CALM architecture document')
    .argument('<document>', 'CALM document file path to generate from')
    .requiredOption('-t, --templates <DIRECTORY>', 'Directory of Handlebars templates to populate')
    .option('-o, --output <DIRECTORY>', 'Directory to output files to. If not set, output to STDOUT separated by --')
    .option('-v, --verbose', 'Whether to do verbose level logging', false)
    .action(async (arg, options) => {
        const outputMap = await generate(arg, options.templates, options.verbose); 

        if (!options.output) {
            const outputString = zipYamlDocs(Array.from(outputMap.values()));
            console.log(outputString);
        }
        else {
            await writeFiles(options.output, outputMap);
        }
    });

async function writeFiles(outputDirectory: string, outputFiles: Map<string, string>) {
    console.log("writing to " + outputDirectory)
    await fs.mkdir(outputDirectory);
    for (const [template, output] of outputFiles) {
        await fs.writeFile(path.join(outputDirectory, template), output, { encoding: 'utf-8' });
    }
}

function zipYamlDocs(docs: string[]): string {
    return "---\n" + docs.join("\n---\n");
}


program.parse();