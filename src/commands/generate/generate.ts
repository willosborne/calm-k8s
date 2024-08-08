import Handlebars from "handlebars";
import { promises as fs } from 'node:fs';
import { buildParameters, parseCalmDoc } from "./parse-calm.js";

async function loadTemplate(filename: string) {
    const templateFile = await fs.readFile(filename, { encoding: 'utf-8' })
    return Handlebars.compile(templateFile);
}

async function getServiceTemplate() {
    return await loadTemplate("src/templates/service.yaml");
}

async function getDeploymentTemplate() {
    return await loadTemplate("src/templates/deployment.yaml");
}

async function loadCalm(filename: string, debug: boolean) {
    if (debug)
        console.log("loading calm file from " + filename)
    
    const data = await fs.readFile(filename, { encoding: 'utf-8' });
    return JSON.parse(data);
}

function zipYamlDocs(docs: string[]): string {
    return docs.join("\n---\n");
}

export default async function(filename: string, debug: boolean) {
    if (debug)
        console.log("generating from " + filename);
    const serviceTemplate = await getServiceTemplate();
    const deploymentTemplate = await getDeploymentTemplate();

    const calm = await loadCalm(filename, debug);
    if (debug) {
        console.log("Loaded CALM: ", calm);
    }

    const calmProperties = parseCalmDoc(calm);

    const parameters = buildParameters(calmProperties);

    const service = serviceTemplate(parameters)
    const deployment = deploymentTemplate(parameters);

    const outputValues = [service, deployment];
    const output = zipYamlDocs(outputValues);

    console.log(output);
    return output;
}