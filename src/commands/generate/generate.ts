import Handlebars from "handlebars";
import { promises as fs } from 'node:fs';

async function serviceTemplate() {
    const templateFile = await fs.readFile("templates/service.template.yaml", { encoding: 'utf-8' });
    console.log(templateFile)
    return Handlebars.compile(templateFile);
}

export default async function(filename: string) {
    console.log("generating from " + filename);
    const template = await serviceTemplate();
    const out = template({
        'port': 1234,
        'targetPort': 12345,
        'name': "egg",
        'label': 'label'
    })
    console.log(out)
    return out;
}