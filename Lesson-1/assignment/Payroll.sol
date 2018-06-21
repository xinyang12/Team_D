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

    function updateEmployee(address _employee, uint _salaryInEther) public onlyOwner {
        // Sending remaining salary to the previous employee.
        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / PAY_DURATION;
            employee.transfer(payment);
        }

        employee = _employee;
        salary = _salaryInEther * 1 ether;
        lastPayday = now;
    }

    /// @dev Update salary for the same employee.
    function updateSalary(uint _salaryInEther) public onlyOwner {
        // No-op if no change.
        if (_salaryInEther * 1 ether == salary) {
            return;
        }
        updateEmployee(employee, _salaryInEther);
    }

    /// @dev Only update the address, not changing employee.
    function updateAddress(address _employee) public onlyOwner {
        require(_employee != 0x0);
        // No-op if same employee.
        if (_employee == employee) {
            return;
        }
        updateEmployee(_employee, salary / 1 ether);
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
