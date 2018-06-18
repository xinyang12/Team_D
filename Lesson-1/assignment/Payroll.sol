pragma solidity ^0.4.14;


contract Payroll {
    uint constant PAY_DURATION = 10 seconds;

    address public owner;

    uint salary;
    address employee;
    uint lastPayday;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function updateEmployee(address _employee, uint _salary) public onlyOwner {
        // Sending remaining salary to the previous employee.
        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / PAY_DURATION;
            employee.transfer(payment);
        }

        employee = _employee;
        salary = _salary * 1 ether;
        lastPayday = now;
    }

    /// @dev Update salary for the same employee.
    function updateSalary(uint _salary) public onlyOwner {
        salary = _salary;
    }

    /// @dev Only update the address, not changing employee.
    function updateAddress(address _employee) public onlyOwner {
        require(_employee != 0x0);
        employee = _employee;
    }

    function addFund() public payable returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        return address(this).balance / salary;
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        require(msg.sender == employee);

        uint nextPayday = lastPayday + PAY_DURATION;
        require(nextPayday < now);

        lastPayday = nextPayday;
        employee.transfer(salary);
    }

}
