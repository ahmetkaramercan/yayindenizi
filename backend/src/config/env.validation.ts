import * as Joi from 'joi';

export const envValidationSchema = Joi.object({
  // Server
  PORT: Joi.number().default(3000),
  CORS_ORIGIN: Joi.string().default('*'),

  // Database
  DATABASE_URL: Joi.string().uri().required().messages({
    'string.empty': 'DATABASE_URL is required',
    'any.required': 'DATABASE_URL is required',
  }),
  DIRECT_URL: Joi.string().uri().required().messages({
    'string.empty': 'DIRECT_URL is required',
    'any.required': 'DIRECT_URL is required',
  }),

  // JWT
  JWT_SECRET: Joi.string().min(16).required().messages({
    'string.min': 'JWT_SECRET must be at least 16 characters',
    'any.required': 'JWT_SECRET is required',
  }),
  JWT_EXPIRES_IN: Joi.string().default('7d'),
  JWT_REFRESH_EXPIRES_IN: Joi.string().default('30d'),
});
