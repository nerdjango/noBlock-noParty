const Event = artifacts.require("Event");
const truffleAssert = require("truffle-assertions")

contract("Event", accounts => {
    it("should assert event roles.", async() => {
        let event = await Event.deployed()
        owner = await event.owner()
        assert.equal(owner, accounts[0])
    })
})