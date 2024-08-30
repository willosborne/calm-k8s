import jp from 'jsonpath';
import { ConstantProperties, ExtractedProperties, PropertyJsonPaths } from './model/pattern-config.js';
import { assertUnique } from './utils.js';
import { join } from 'path';

export function getCalmNodeById(uniqueId: string, calmDocument: object): object {
    const jsonPath = `$.nodes[?(@["unique-id"]=='${uniqueId}')]`;

    assertUnique(calmDocument, jsonPath, "No node, or multiple, found with unique-id " + uniqueId)
    const node = jp.value(calmDocument, jsonPath)
    return node
}

export function parseTemplatePropertiesFromCalmObject(requestedProperties: PropertyJsonPaths, 
    calmObject: object): ExtractedProperties {

    const out: ExtractedProperties = {}
    Object.keys(requestedProperties).forEach((key) => {
        console.log("Calm object: " + JSON.stringify(calmObject))
        const path = requestedProperties[key]
        console.log("path: " + path)

        assertUnique(calmObject, path, "Could not find a match for for the requested JSONPath " + path)
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