import Account "account";
import TrieMap "mo:base/TrieMap";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";

actor BEICoin {
    type Account = Account.Account;

    let ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);
    private var students = TrieMap.TrieMap<Principal, Bool>(Principal.equal, Principal.hash);

    public shared query func name(): async Text {
        "BEICoin"
    };

    public shared query func symbol(): async Text {
        "BEI"
    };

    public shared query func totalSupply(): async Nat {
        var total = 0;
        for (balance in ledger.vals()) {
            total += balance;
        };
        total
    };

    public shared query func balanceOf(account: Account): async Nat {
        switch (ledger.get(account)) {
            case null { 0 };
            case (?balance) { balance };
        }
    };

public shared func transfer(from: Account, to: Account, amount: Nat): async Result.Result<(), Text> {
        Debug.print("Initiating transfer...");
        Debug.print("From account: " # debug_show(from));
        Debug.print("To account: " # debug_show(to));
        Debug.print("Amount to transfer: " # debug_show(amount));

        // Fetch balance of the sender
        let fromBalance = switch (ledger.get(from)) {
            case null { 0 };
            case (?balance) { balance };
        };

        Debug.print("From balance: " # debug_show(fromBalance));

        if (fromBalance < amount) {
            Debug.print("Error: Insufficient balance!");
            return #err("Insufficient balance");
        };

        // Deduct amount from sender
        ledger.put(from, fromBalance - amount);
        Debug.print("Updated from balance: " # debug_show(fromBalance - amount));

        let toBalance = switch (ledger.get(to)) {
            case null { 0 };
            case (?balance) { balance };
        };

        Debug.print("To balance before transfer: " # debug_show(toBalance));

        // Add amount to recipient
        let newBalance = toBalance + amount;
        ledger.put(to, newBalance);

        Debug.print("To balance after transfer: " # debug_show(newBalance));
        return #ok(());
    };



    public shared func addStudent(student: Principal): async Result.Result<(), Text> {
        students.put(student, true);
        #ok(())
    };

    public shared func airdrop(): async Result.Result<(), Text> {
    try {
        for (studentPrincipal in students.keys()) {
            let studentAccount = { owner = studentPrincipal; subaccount = null };
            let currentBalance = switch (ledger.get(studentAccount)) {
                case null { 0 };
                case (?balance) { balance };
            };
            ledger.put(studentAccount, currentBalance + 100);
            Debug.print("Airdropped to: " # debug_show(studentPrincipal));
        };
        #ok(())
    } catch (e) {
        Debug.print("Airdrop error: ");
        #err("Failed to perform airdrop:");
    };
};


    public shared (msg) func whoami(): async Principal {
        msg.caller
    };

    public query func getAllStudents(): async [Principal] {
        Iter.toArray(students.keys());
    };

    public query func getAllBalances(): async [(Principal, Nat)] {
        let entries = Iter.map<(Account, Nat), (Principal, Nat)>(ledger.entries(), func((account, balance)) {
            (account.owner, balance)
        });
        Iter.toArray(entries);
    };
};
