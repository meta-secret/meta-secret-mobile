#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

// -----------------------------------------------------------------------
// from strings.rs
// -----------------------------------------------------------------------
struct RustByteSlice {
    const uint8_t *bytes;
    size_t len;
};

// -----------------------------------------------------------------------
// from rust_to_swift.rs
// -----------------------------------------------------------------------
struct keys_pair;
struct keys_pair *new_keys_pair(void);
void keys_pair_destroy(struct keys_pair *data);
struct RustByteSlice get_transport_pub(const struct keys_pair *data);
struct RustByteSlice get_transport_sec(const struct keys_pair *data);
struct RustByteSlice get_dsa_pub(const struct keys_pair *data);
struct RustByteSlice get_dsa_key_pair(const struct keys_pair *data);

// -----------------------------------------------------------------------
// from swift_to_rust.rs
// -----------------------------------------------------------------------

//struct swift_object {
//    void *user;
//    void (*destroy)(void *user);
//    void (*callback_with_int_arg)(void *user, int32_t arg);
//};

//void give_object_to_rust(struct swift_object object);
//void utf8_bytes_to_rust(const uint8_t *bytes, size_t len);
struct RustByteSlice split_and_encode(const uint8_t *json_bytes, size_t json_len);
