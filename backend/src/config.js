import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";
import { config } from "dotenv";

config();

async function getSecret(secretName) {
  const client = new SecretsManagerClient({ region: "us-east-1" });
  const command = new GetSecretValueCommand({ SecretId: secretName });

  try {
    const response = await client.send(command);
    console.log("Raw secret fetched:", response);

    return response.SecretString
      ? JSON.parse(response.SecretString)
      : JSON.parse(Buffer.from(response.SecretBinary).toString("utf-8"));
  } catch (error) {
    console.error("Error getting secret:", error);
    throw error;
  }
}

export async function loadConfig() {
  try {
    const secret = await getSecret("devexchsvc-secret-dev");
    console.log("Parsed secret:", secret);

    process.env.PGUSER = secret.username;
    process.env.PGPASSWORD = secret.password;
    process.env.PGHOST = secret.host;
    process.env.PGDATABASE = secret.database;
    process.env.PGPORT = secret.port;

    console.log("Final DB Config:");
    console.log({
      user: process.env.PGUSER,
      password: process.env.PGPASSWORD,
      host: process.env.PGHOST,
      database: process.env.PGDATABASE,
      port: process.env.PGPORT,
    });

    console.log("Secret and DB config loaded successfully!");
  } catch (error) {
    console.error("Failed to load config:", error);
    throw error;
  }
}
