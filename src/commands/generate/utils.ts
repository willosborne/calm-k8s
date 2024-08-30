import jp from 'jsonpath';

export function assertUnique(data: object, jsonPath: string, message: string): void {
    const matches = jp.query(data, jsonPath).length;
    if (matches != 1) {
        console.log(message);
        throw new Error(message);
    }
}