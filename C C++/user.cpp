
#include "user.hpp"
#include <fstream>
#include <sstream>
#include <stdexcept>
#include "password.hpp"

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
	// Pour éviter d'avoir à gérer la mémoire allouée avec new, on préfère
	// souvent renvoyer un smart pointer. std::make_unique<User>(id, pwd);

	// En fonction des cas, on peut penser à un vecteur/map contenant des User ou des unique_ptr<User>
	// Cela permet d'avoir un conteneur qui gère la mémoire automatiquement
	// puis de renvoyer une référence ou un pointeur vers l'élément souhaité
	// et ainsi de ne pas avoir à se soucier de la libération de la mémoire
	// std::vector<std::unique_ptr<User>> users;
	// users.push_back(std::make_unique<User>(id, std::move(password)));
	// return users.back();

	// Regardez également du côté de std::move pour utiliser les mêmes blocs mémoire des 2 cotés du return
    throw std::runtime_error("User not found.");
}
