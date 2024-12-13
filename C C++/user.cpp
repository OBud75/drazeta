
#include "user.hpp"
#include <fstream>
#include <sstream>
#include <stdexcept>

User::User(int id, Password &password):
    id(id), password(&password) {
        is_logged_in = false;
};

void User::save() {
    std::ofstream file("users.db", std::ios::app);
    if (!file) throw std::runtime_error("Unable to open file for saving.");

    file << id << "|" << password->str() << "\n";
    file.close();
};

int User::login(char *raw_password) {
    Password temp_password(raw_password, false);
    if (*password == temp_password.str()) {
        is_logged_in = true;
        return 0; 
    }
    return 1; 
};

User& User::get(int id) {
    std::ifstream file("users.db");
    if (!file) throw std::runtime_error("Unable to open file for reading.");

    std::string line;
    while (std::getline(file, line)) {
        std::stringstream ss(line);
        std::string temp_id, temp_password;

        if (std::getline(ss, temp_id, '|') && std::getline(ss, temp_password)) {
            if (std::stoi(temp_id) == id) {
                Password *password = new Password(temp_password, true);
                User *user = new User(id, *password);
                file.close();
                return *user;
            }
        }
    }
    file.close();
    throw std::runtime_error("User not found.");
}
