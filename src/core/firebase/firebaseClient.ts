import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { env } from '../config/env';

const firebaseConfig = {
  apiKey: env.firebaseApiKey,
  authDomain: env.firebaseAuthDomain,
  projectId: env.firebaseProjectId,
  appId: env.firebaseAppId,
};

export const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
