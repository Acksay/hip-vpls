#!/usr/bin/python3

"""
    OBS, Mock toy example stub which will be properly implemented later
"""
class ECBD:
    def __init__(self, nr_of_participants):
        self.nr_of_participants = nr_of_participants
        self.private_key = 2512343124312431222
        self.generator = 2
        self.p = 512343124312431222
        self.index = 1
        self.z_list = [-1] * nr_of_participants
        self.x_list = [-1] * nr_of_participants
        self.shared_key = -1

    def set_index(self, index):
        self.index = index;
        self.private_key*=(self.index+1)
    
    def compute_public_z(self):
        z = (self.generator * self.private_key) % self.p;
        self.z_list[self.index] = z
        return z

    def compute_public_x(self):
        next_index = (self.index + 1) % self.nr_of_participants
        prev_index = (self.index - 1) % self.nr_of_participants
        x = (self.generator * (self.z_list[next_index]-self.z_list[prev_index])) % self.p;
        self.x_list[self.index] = x
        return x

    def compute_shared_key(self):
        self.shared_key = 0;
        for x in self.x_list:
            self.shared_key += x**self.generator
        self.shared_key = self.shared_key % self.p
        return self.shared_key

    def is_z_list_complete(self):
        return -1 in self.z_list

    def is_x_list_complete(self):
        return -1 in self.x_list


    