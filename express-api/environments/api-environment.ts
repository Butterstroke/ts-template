import { config } from 'dotenv';
import environment from '../src/utilities/environment-typing';

let env_vars = config({ 
    path: `${__dirname}/environment.env.${process.env.NODE_ENV || "development"}` 
});

env_vars = env_vars.parsed;

export default env_vars as environment;