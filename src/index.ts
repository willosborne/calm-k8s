#!/usr/bin/env node
import { program } from 'commander';
import template from './commands/generate/template.js';
import * as fs from 'node:fs/promises'
import * as path from 'node:path';

program
    .version('0.1.0');

program.command('template')
    .description('Template Kubernetes resources using CALM architecture as code')
    .argument('<document>', 'File containing a CALM pattern instantiation to generate from')
    .requiredOption('-t, --templates <DIRECTORY>', 'Directory of Handlebars templates to populate')
    .option('-o, --output <DIRECTORY>', 'Directory to output files to. If not set, output to STDOUT separated by --')
    .option('-v, --verbose', 'Whether to do verbose level logging', false)
    .action(async (arg, options) => {
        const outputMap = await template(arg, options.templates, options.verbose); 

        if (!options.output) {
            const outputString = zipYamlDocs(Array.from(outputMap.values()));
            console.log(outputString);
        }
        else {
            await writeFiles(options.output, outputMap);
        }
    });

async function writeFiles(outputDirectory: string, outputFiles: Map<string, string>) {
    console.log(`Writing files to directory '${outputDirectory}'`)
    await fs.mkdir(outputDirectory, { recursive: true });
    for (const [template, output] of outputFiles) {
        const outputPath = path.join(outputDirectory, template)
        await fs.writeFile(outputPath, output, { encoding: 'utf-8' });
        if (template.endsWith('.sh')) {
            await fs.chmod(outputPath, '755')
        }
    }
}

function zipYamlDocs(docs: string[]): string {
    return "---\n" + docs.join("\n---\n");
}


program.parse();