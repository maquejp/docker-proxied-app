/**
 * Account interface representing the accounts table
 */
export interface Account {
  pk: number;
  givenname: string;
  lastname: string;
  unikid: string;
  email: string;
  created_on: Date;
  modified_on: Date;
  created_by: string;
  modified_by: string;
}

/**
 * Account creation DTO - excludes auto-generated fields
 */
export interface CreateAccountDTO {
  givenname: string;
  lastname: string;
  unikid: string;
  email: string;
  created_by: string;
}

/**
 * Account update DTO - includes pk and modifiable fields
 */
export interface UpdateAccountDTO {
  pk: number;
  givenname: string;
  lastname: string;
  unikid: string;
  email: string;
  modified_by: string;
}

/**
 * Account query filters
 */
export interface AccountFilter {
  givenname?: string;
  lastname?: string;
  unikid?: string;
  email?: string;
  created_by?: string;
}

/**
 * Account response DTO for API responses
 */
export interface AccountResponseDTO {
  pk: number;
  givenname: string;
  lastname: string;
  unikid: string;
  email: string;
  created_on: string; // ISO string format
  modified_on: string; // ISO string format
  created_by: string;
  modified_by: string;
  fullname: string; // computed field
}
