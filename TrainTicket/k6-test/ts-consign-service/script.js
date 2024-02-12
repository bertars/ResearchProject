/*
 * Api Documentation
 * Api Documentation
 *
 * OpenAPI spec version: 1.0
 *
 * NOTE: This class is auto generated by OpenAPI Generator.
 * https://github.com/OpenAPITools/openapi-generator
 *
 * OpenAPI generator version: 6.0.1-SNAPSHOT
 */


import http from "k6/http";
import { group, check, sleep } from "k6";

const BASE_URL = "http://145.108.225.7:16111";
// Sleep duration between successive requests.
// You might want to edit the value of this variable or remove calls to the sleep function on the script.
const SLEEP_DURATION = 0.1;
// Global variables should be initialized.
const TS_AUTH_SERVICE_URL = "http://145.108.225.7:12340";
const USERNAME = 'admin';
const PASSWORD = '222222';

export function setup() {
    // authenticate via a Bearer token
    let params = {headers: {"Content-Type": "application/json", "Accept": "*/*"}};
    let body = {"username": USERNAME, "password": PASSWORD};
    const loginRes = http.post(`${TS_AUTH_SERVICE_URL}/api/v1/users/login`, JSON.stringify(body), params);

    const authToken = loginRes.json('data')["token"];
    check(authToken, { 'Logged in successfully': () => authToken !== '' });

    return authToken;
}

export default function(authToken) {
    let params = {headers: {"Authorization": `Bearer ${authToken}`, "Content-Type": "application/json", "Accept": "*/*"}};

    group("/api/v1/consignservice/consigns/{consignee}", () => {
        let consignee = 'Madalina';

        // Request No. 1
        {
            let url = BASE_URL + `/api/v1/consignservice/consigns/${consignee}`;
            let request = http.get(url, params);

            check(request, {
                "GET OK": (r) => r.status === 200
            });
        }
    });

    group("/api/v1/consignservice/consigns", () => {

        // Request No. 1
        {
            let url = BASE_URL + `/api/v1/consignservice/consigns`;
            let body = {
                "accountId": "4d2a46c7-71cb-4cf1-b5bb-b68406d9da6f",
                "handleDate": "2022-06-28",
                "targetDate": "2022-06-28 11:56:57",
                "from": "Shang Hai",
                "to": "Tai Yuan",
                "orderId": "343cfd59-bff1-4199-b530-6ec79758bcbc",
                "consignee": "Madalina",
                "phone": "12082",
                "weight": "50",
                "id": "",
                "isWithin": false
            }
            let request = http.put(url, JSON.stringify(body), params);

            check(request, {
                "PUT OK": (r) => r.status === 200
            });

            sleep(SLEEP_DURATION);
        }

        // Request No. 2
        {
            let url = BASE_URL + `/api/v1/consignservice/consigns`;
            let body = {"accountId": "153632a9-14eb-44f1-7b89-7431fea1cba3", "consignee": "string", "from": "string", "handleDate": "string", "id": "153632a9-14eb-44f1-7b89-7431fea1cba3", "orderId": "153632a9-14eb-44f1-7b89-7431fea1cbde", "phone": "string", "targetDate": "string", "to": "string", "weight": 20000, "within": true};
            let request = http.post(url, JSON.stringify(body), params);

            check(request, {
                "POST OK": (r) => r.status === 200
            });
        }
    });

    group("/api/v1/consignservice/consigns/account/{id}", () => {
        let id = '153632a9-14eb-44f1-7b89-7431fea1cba3';

        // Request No. 1
        {
            let url = BASE_URL + `/api/v1/consignservice/consigns/account/${id}`;
            let request = http.get(url, params);

            check(request, {
                "GET OK": (r) => r.status === 200
            });
        }
    });

    group("/api/v1/consignservice/consigns/order/{id}", () => {
        let id = '153632a9-14eb-44f1-7b89-7431fea1cbde';

        // Request No. 1
        {
            let url = BASE_URL + `/api/v1/consignservice/consigns/order/${id}`;
            let request = http.get(url, params);

            check(request, {
                "GET OK": (r) => r.status === 200
            });
        }
    });

    group("/api/v1/consignservice/welcome", () => {

        // Request No. 1
        {
            let url = BASE_URL + `/api/v1/consignservice/welcome`;
            let request = http.get(url, params);

            check(request, {
                "GET OK": (r) => r.status === 200
            });
        }
    });
}
