const Event = artifacts.require("Event");
const truffleAssert = require("truffle-assertions")

contract("Event", accounts => {
    it("should assert event admin role.", async() => {
        let event = await Event.deployed()
        let owner = await event.owner()
        assert.equal(owner, accounts[0])
        await truffleAssert.passes(event.isAdmin(accounts[0]))
        await truffleAssert.passes(event.isAdmin(accounts[1]))
        await truffleAssert.passes(event.isAdmin(accounts[2]))
        await truffleAssert.passes(event.isAdmin(accounts[3]))
        await truffleAssert.reverts(event.isAdmin(accounts[4]))
        let numOfAdmins = await event.numOfAdmins()
        assert.equal(numOfAdmins.toNumber(), 4)
        let list = []
        list.push(accounts[2])
        list.push(accounts[3])
        await event.removeAdmins(list)
        await truffleAssert.reverts(event.isAdmin(accounts[2]))
        await truffleAssert.reverts(event.isAdmin(accounts[3]))
        list = []
        list.push(accounts[4])
        await event.addAdmins(list)
        numOfAdmins = await event.numOfAdmins()
        assert.equal(numOfAdmins.toNumber(), 3)
    })
    it("should allow registration of participants if conditions are met.", async() => {
        let event = await Event.deployed()
    })
})