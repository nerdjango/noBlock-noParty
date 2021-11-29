const Event = artifacts.require("Event");

module.exports = function(deployer) {
    adminList = [accounts[1], accounts[2], accounts[3]]
    deployer.deploy(Event, adminList);
};