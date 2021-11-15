// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract TodoList {
    

    struct Task {
        string taskName;
        bool isCompleted;
    }

    Task[] public tasks;

    event TaskCreated(string task, uint taskNumber);

    constructor() {
        tasks.push(Task("Task Test", true));
        
    }

    function getTasksLength() view public returns(uint){
        return tasks.length;
    }

    function createTask(string memory _taskName) public {
        // add task to mapping
        // increment taskCount
        tasks.push(Task(_taskName, false));

        // emit event
        emit TaskCreated(_taskName, tasks.length - 1);
    }
}
