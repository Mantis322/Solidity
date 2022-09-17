pragma solidity ^0.8.17;

// SPDX-License-Identifier: MIT

contract ToDo{
    
    // Struct için ihtiyacımız olan değişkenleri tanımlama / Declare the variables we need for the struct
    struct Todo{
        string text;
        bool completed;
    }

    // todos array'ini tanımlama / Declare todos array
    Todo[] public todos;

    function create(string calldata _text) external {
        todos.push(Todo({
            text : _text,
            completed : false
        }));
    }

    function update(uint _index,string calldata _text) external {
        todos[_index].text = _text;
        //Todo storage todo = todos[_index];
        //todo.text = _text;

    }

    function get(uint _index) external view returns(string memory, bool){
        Todo storage todo = todos[_index];
        return (todo.text, todo.completed);
    }

    function toggleCompleted(uint _index) external {
        todos[_index].completed = !todos[_index].completed; 
    }
}
