import Handlebars from "handlebars";
import { promises as fs } from 'node:fs';
import { getCalmNodeById, parseTemplatePropertiesFromCalmObject } from "./parse-calm.js";
import { ConstantProperties, ExtractedProperties, NodeConfig, parsePatternConfig, TemplateConfig } from "./model/pattern-config.js";
import { combinePropertes } from "./utils.js";

async function loadCalm(filename: string, debug: boolean) {
    if (debug)
        console.log("loading calm file from " + filename)
    
    const data = await fs.readFile(filename, { encoding: 'utf-8' });
    return JSON.parse(data);
}

function zipYamlDocs(docs: string[]): string {
    return "---\n" + docs.join("\n---\n");
}


async function loadTemplate(filename: string): Promise<HandlebarsTemplateDelegate> {
    const fileContent = await fs.readFile(filename, 'utf-8');
    return Handlebars.compile(fileContent);
}

export default async function(calmFilename: string, patternConfigFilename: string, debug: boolean) {
    if (debug)
        console.log("generating from CALM document " + calmFilename + ", pattern config " + patternConfigFilename);

    const calm = await loadCalm(calmFilename, debug);
    if (debug) {
        console.log("Loaded CALM: ", calm);
    }

    const patternConfig = await parsePatternConfig(patternConfigFilename);
    const globalProperties = !!patternConfig?.globals?.properties 
        ? parseTemplatePropertiesFromCalmObject(patternConfig.globals.properties, calm) 
        : {};

    const constants = !!patternConfig?.globals?.constants 
        ? patternConfig.globals.constants
        : {};

    const outputValues = []

    for (const nodeConfig of patternConfig.nodes) {
        outputValues.push(...await generateNode(nodeConfig, globalProperties, constants, calm));
    }

    const output = zipYamlDocs(outputValues);

    return output;
}

async function generateNode(config: NodeConfig, globalProperties: ExtractedProperties, constants: ConstantProperties, calmDocument: object): Promise<string[]> {
    const calmObject = getCalmNodeById(config['unique-id'], calmDocument);
    console.log("calm object parsed: " + JSON.stringify(calmObject))
    const output = [];

    for (const templateConfig of config.templates) {
        const template = await loadTemplate(templateConfig.filename);
        const properties: ExtractedProperties = parseTemplatePropertiesFromCalmObject(
            templateConfig.properties, calmObject
        );

        const merged = combinePropertes(properties, globalProperties, constants)
        output.push(template(merged));
    }

    return output;
}