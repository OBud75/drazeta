#include "password.hpp"
#include <openssl/sha.h>
#include <sstream>
#include <iomanip>

Password::Password(const std::string &password, bool is_encrypted):
    _raw_value(password) {
        if (is_encrypted) {
            _encrypted_value = password;
        } else {
            encrypt(password);
        }
};

void Password::encrypt(const std::string &password) {
    // Implementation using SHA-256
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256(reinterpret_cast<const unsigned char*>(password.c_str()), password.size(), hash);

    std::stringstream ss;
    for (int i = 0; i < SHA256_DIGEST_LENGTH; ++i) {
        ss << std::hex << std::setw(2) << std::setfill('0') << (int)hash[i];
    }
    _encrypted_value = ss.str();
};

std::string Password::str() const {
    return _encrypted_value;
}

bool Password::operator==(const std::string &str) const {
    return str == _encrypted_value;
}

bool Password::operator==(const Password &other) const {
    return _encrypted_value == other._encrypted_value;
}

std::ostream &operator<<(std::ostream &os, const Password &p) {
    os << p._encrypted_value;
    return os;
}