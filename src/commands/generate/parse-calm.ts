import jp from 'jsonpath';
import { Parameters } from './types.js';
import { Exception } from 'handlebars';
import { ExtractedProperties, PropertyJsonPaths } from './model/pattern-config.js';

// const jsonPaths = new Map<string, string>([
//     ['appName', `$.nodes[1]['unique-id']`],
//     ['image', '$.nodes[1].interfaces[0].image'],
//     ['port', '$.nodes[1].interfaces[1].port'],
// ])

// function extractPropertiesByJsonPath(calmDocument: object, jsonPaths: Map<string, string>): Map<string, string> {
//     const out = new Map<string, string>();
//     for (const [key, path] of jsonPaths) {
//         const value: string = jp.value(calmDocument, path)

//         if (!value) {
//             console.error("Coudn't find a key for the given json path in the CALM document. Key: ", key, ", JSONPath: ", path);
//             throw Error("bad jsonpath")
//         }

//         out.set(key, value);
//     }

//     return out;
// }

// export function parseCalmDoc(calmDocument: object) {
//     return extractPropertiesByJsonPath(calmDocument, jsonPaths);
// }

function getProp(props: Map<string, string>, prop: string): string {
    const val = props.get(prop);
    if (!val) {
        const msg = `Could not find property ${prop}. Could there be a missing JSONPath?` 
        throw Error(msg);
    }
    return val;
}

export function buildParameters(props: Map<string, string>): Parameters {
    return {
        image: getProp(props, 'image'),
        port: Number.parseInt(getProp(props, 'port')),
        targetPort: Number.parseInt(getProp(props, 'port')),
        appName: getProp(props, 'appName'),
        serviceName: getProp(props, 'appName')+ "-svc"
    }
}

export function getCalmNodeById(uniqueId: string, calmDocument: object): object {
    const jsonPath = `$.nodes[?(@["unique-id"]=='${uniqueId}')]`;
    // console.log("constructred jsonPath: " + jsonPath)

    const node = jp.value(calmDocument, jsonPath)
    // console.log("extracted node: " + node)
    return node
}

export function parseTemplatePropertiesFromCalmObject(requestedProperties: PropertyJsonPaths, 
    calmObject: object): ExtractedProperties {

    const out: ExtractedProperties = {}
    Object.keys(requestedProperties).forEach((key) => {
        console.log("Calm object: " + JSON.stringify(calmObject))
        const path = requestedProperties[key]
        console.log("path: " + path)

        const value: string = jp.value(calmObject, path)

        if (!value) {
            console.error("Coudn't find a key for the given json path in the CALM document. " +
                "Key: ", key, ", JSONPath: ", path);
            throw Error("bad jsonpath")
        }

        out[key] = value;
    })

    return out;
}