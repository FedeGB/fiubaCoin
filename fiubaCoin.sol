pragma solidity ^0.4.21;

contract fiubaCoin {
    // The keyword "public" makes those variables
    // readable from outside.
    address public minter;
    mapping (address => uint) public balances;

    // Events allow light clients to react on
    // changes efficiently.
    event Sent(address from, address to, uint amount);

    // This is the constructor whose code is
    // run only when the contract is created.
    constructor() public {
        minter = msg.sender;
        balances[msg.sender] = 10000;
    }

    function mint(address receiver, uint amount) public {
        if (msg.sender != minter) return;
        balances[receiver] += amount;
    }

    function send(address receiver, uint amount) public {
        // if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}


contract RockPaperScissors {
    
    struct Person {
        uint64 cuil;
        string nombre;
        address blockDir;
    }

    enum gambleOption {PIEDRA, PAPEL, TIJERA}
    
    struct Apuesta {
        gambleOption eleccion;
        uint dinero;
    }

    // mapping (address => Person) public participants;

    address public creator;
    uint public createdAt;

    Person public gambler01;
    Person public gambler02;

    Apuesta private apuesta01;
    Apuesta private apuesta02;


    constructor() public {
        creator = msg.sender;
        createdAt = now; 
        // Da el timestamp de la blockchain.. lo cual es dudoso, pero no hay forma de obtener un time real..
    }

    function setApostador01(uint64 cuil01, string name01, address blockDir01) public {
        require(msg.sender == creator, "Solo el creador de la apuesta puede setear postadores");
        gambler01 = Person({cuil: cuil01, nombre: name01, blockDir: blockDir01});

    }

    function setApostador02(uint64 cuil02, string name02, address blockDir02) public {
        require(msg.sender == creator, "Solo el creador de la apuesta puede setear postadores");
        gambler02 = Person({cuil: cuil02, nombre: name02, blockDir: blockDir02});
    }

    function apostar(uint money, gambleOption election) public {
        require(election == gambleOption.PIEDRA || election == gambleOption.PAPEL || election == gambleOption.TIJERA, "La eleccion no es valida");
        Apuesta memory entrante = Apuesta({eleccion: election, dinero: money});
        if(msg.sender == gambler01.blockDir) {
            apuesta01 = entrante;
        } else if(msg.sender == gambler02.blockDir) {
            apuesta02 = entrante;
        } else {
            revert("Solo los que forman parte de la apuesta pueden apostar");
        }

        if(apuesta01.dinero > 0 && apuesta02.dinero > 0) {
            address sender;
            address receiver;
            uint cash;
            if(resolveGame(apuesta01.eleccion, apuesta02.eleccion)) {
                sender = gambler02.blockDir;
                receiver = gambler01.blockDir;
            } else {
                sender = gambler01.blockDir;
                receiver = gambler02.blockDir;
            }
            if(apuesta01.dinero < apuesta02.dinero) {
                cash = apuesta01.dinero;
            } else {
                cash = apuesta02.dinero;
            }
            fiubaCoin token = fiubaCoin(sender);
            token.send(receiver, cash);
            
                
        }
    }

    function resolveGame(gambleOption first, gambleOption second) internal pure returns(bool) {
        if(first == gambleOption.PIEDRA && second == gambleOption.PAPEL) {
            return false;
        }
        if(first == gambleOption.PIEDRA && second == gambleOption.TIJERA) {
            return true;
        }
        if(first == gambleOption.PAPEL && second == gambleOption.TIJERA) {
            return false;
        }
        if(first == gambleOption.PAPEL && second == gambleOption.PIEDRA) {
            return true;
        }
        if(first == gambleOption.TIJERA && second == gambleOption.PAPEL) {
            return true;
        }
        if(first == gambleOption.TIJERA && second == gambleOption.PIEDRA) {
            return false;
        }
    }

}