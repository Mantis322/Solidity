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

    //Bu fonksiyon ile yaratılan structlar todos arrayine atılır / The structs that created with this function are thrown into the todos array.
    function create(string calldata _text) external {
        // Girilen parametreleri array içine atar / Throw the entered parameters into the array
        todos.push(Todo({
            text : _text,
            completed : false
        }));
    }
    
    // Çağrılan index içindeki parametreleri güncelleyen fonksiyon / Function that updates parameters in the called index
    function update(uint _index,string calldata _text) external {
        todos[_index].text = _text;
        //Todo storage todo = todos[_index];
        //todo.text = _text;

    }

    //Çağrılan index içindeki parametreleri getirir(Ekstra gas'a mal olur) / Returns parameters in the called index(Costs extra gas)
    function get(uint _index) external view returns(string memory, bool){
        Todo storage todo = todos[_index];
        return (todo.text, todo.completed);
    }
    
    //Completed parametresini değiştirir / Changes the Completed parameter
    function toggleCompleted(uint _index) external {
        todos[_index].completed = !todos[_index].completed; 
    }
}
