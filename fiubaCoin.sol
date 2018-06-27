pragma solidity ^0.4.21;

contract fiubaCoin {
    
    struct Person {
        uint64 cuil;
        string nombre;
        address blockDir;
    }

    enum gambleOption {PIEDRA, PAPEL, TIJERA}
    
    struct Apuesta {
        gambleOption eleccion;
        int dinero;
    }

    address public creator;
    uint public createdAt;

    Person public gambler01;
    Person public gambler02;

    Apuesta private apuesta01;
    Apuesta private apuesta02;

    mapping (address => int) public balances;

    event Sent(address from, address to, int amount);

    constructor() public payable {
        creator = msg.sender;
        createdAt = now;
        balances[msg.sender] = 10000;
    }

    function mint(address receiver, int amount) public {
        if (msg.sender != creator) return;
        balances[receiver] += amount;
    }

    function transfer(address sender, address receiver, int amount) internal {
        require(amount > 0, "Transferencias deben ser con montos positivos");
        balances[sender] -= amount;
        balances[receiver] += amount;
        emit Sent(sender, receiver, amount);
    }

    function setApostador01(uint64 cuil01, string name01, address blockDir01) public {
        require(msg.sender == creator, "Solo el creador de la apuesta puede setear postadores");
        gambler01 = Person({cuil: cuil01, nombre: name01, blockDir: blockDir01});

    }

    function setApostador02(uint64 cuil02, string name02, address blockDir02) public {
        require(msg.sender == creator, "Solo el creador de la apuesta puede setear postadores");
        gambler02 = Person({cuil: cuil02, nombre: name02, blockDir: blockDir02});
    }

    function apostar(int money, gambleOption election) public payable {
        require(election == gambleOption.PIEDRA || election == gambleOption.PAPEL || election == gambleOption.TIJERA, "La eleccion no es valida");
        require(money > 0, "Las apuestas deben ser positivas");
        Apuesta memory entrante = Apuesta({eleccion: election, dinero: money});
        if(msg.sender == gambler01.blockDir) {
            apuesta01 = entrante;
        } else if(msg.sender == gambler02.blockDir) {
            apuesta02 = entrante;
        } else {
            revert("Solo los que forman parte de la apuesta pueden apostar");
        }
        resolveGamble();
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
        // En caso de empate gana el primero en apostar
        return true;
    }
    
    function resolveGamble() internal {
        if(apuesta01.dinero > 0 && apuesta02.dinero > 0) {
            address sender;
            address receiver;
            int cash;
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
            transfer(sender, receiver, cash);
            clearGamble();
        }
    }

    function clearGamble() internal {
        delete gambler01;
        delete gambler02;
        delete apuesta01;
        delete apuesta02;
    }

}
