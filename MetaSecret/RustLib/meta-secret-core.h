#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

char* generate_signed_user(const uint8_t *vault_name_bytes, size_t json_len);
char* split_secret(const uint8_t *strings_bytes, size_t string_len);
char* encrypt_secret(const uint8_t *json_bytes, size_t json_len);
char* decrypt_secret(const uint8_t *json_bytes, size_t json_len);
char* generate_meta_password_id(const uint8_t *password_id, size_t json_len);
char* restore_secret(const uint8_t *json_bytes, size_t json_len);
void rust_string_free(char *s);
