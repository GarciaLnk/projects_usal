pragma solidity >0.5.0;
pragma experimental ABIEncoderV2;

contract ProductContract {
    address productManufacturer;
    address potentialCustodian;

    struct Product {
        string trackingID;
        string productName;
        string health;
        bool sold;
        address custodian; // quien actualmente tiene producto
        uint256 timestamp;
        string lastScannedAt;
        string[] misc;
        // array para almacenar las claves públicas de los potenciales propietarios del producto
        string[] participants;
    }

    struct Transaction {
        address custodian;
        uint256 timestamp;
        string lastScannedAt;
    }

    /**
     *@dev array con todos los productos creados
     */
    Product[] public allProducts;
    string[] public productKeys;

    mapping(string => Product) productSupplyChain;
    mapping(string => Transaction[]) history;

    event locationEvent(string trackingID, string location);
    event sendTrackingID(string);

    /**
     * @dev quien despliegue el contrato será marcado como fabricante
     */
    constructor() public {
        productManufacturer = msg.sender;
    }

    /**
     * @dev limita y comprueba que el que fabricante sea el único que puede ejecutar la tarea
     */
    modifier onlyManufacturer() {
        require(
            msg.sender == productManufacturer
        );
        _;
    }

    /**
     *@return devuelve un nuevo producto
     *@dev solo se ejecuta si el que llama la función es el fabricante
     */
    function addProduct(
        string memory _trackingID,
        string memory _productName,
        string memory _health,
        string[] memory _misc,
        string memory _lastScannedAt,
        string[] memory _participants
    ) public onlyManufacturer returns (Product memory) {
        require(
            // comprueba que el 
            bytes(productSupplyChain[_trackingID].trackingID).length <= 0
        );
        uint256 _timestamp = block.timestamp;
        bool _sold = false;
        address _custodian = msg.sender;

        Product memory newProduct = Product(
            _trackingID,
            _productName,
            _health,
            _sold,
            _custodian,
            _timestamp,
            _lastScannedAt,
            _misc,
            _participants
        );
        allProducts.push(newProduct);
        productKeys.push(_trackingID);
        productSupplyChain[_trackingID] = newProduct;

        Transaction memory newTransaction = Transaction(
            _custodian,
            _timestamp,
            _lastScannedAt
        );
        history[_trackingID].push(newTransaction);

        emit sendTrackingID(_trackingID);
        return newProduct;
    }

    function getProductsLength() public view returns (uint256) {
        return allProducts.length;
    }

    function getProductAt(uint256 index) public view returns (Product memory) {
        string memory trackingID = productKeys[index - 1];
        return productSupplyChain[trackingID];
    }

    function addressToString(address _addr)
        internal
        pure
        returns (string memory)
    {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(value[i + 12] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    }

    function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint256 i = 0; i < bStr.length; i++) {
            // Uppercase character...
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                // So we add 32 to make it lowercase
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    /**
     *@dev actualiza el propietario actual del producto usando el trackingID
     */
    function updateCustodian(string memory _productID, string memory location)
        public
        returns (string memory, string memory)
    {
        require(
            bytes(productSupplyChain[_productID].trackingID).length > 0
        ); // comprueba que el producto existe en la cadena de suministros

        address newCustodian;
        string memory ourAddress = addressToString(msg.sender);
        bool isParticipant = false;
        string memory _trackingID;
        bytes memory yourIdentity = abi.encodePacked(ourAddress);

        for (
            uint256 i = 0;
            i < productSupplyChain[_productID].participants.length;
            i++
        ) {
            string memory participant = _toLower(
                productSupplyChain[_productID].participants[i]
            );
            if (
                keccak256(yourIdentity) ==
                keccak256(abi.encodePacked((participant)))
            ) {
                newCustodian = msg.sender;
                _trackingID = productSupplyChain[_productID].trackingID;
                isParticipant = true;
            }
        }
        require(
            isParticipant
        ); // comprueba que quien hace la llamada está en la lista de participantes

        uint256 _timestamp = block.timestamp;
        productSupplyChain[_productID].custodian = msg.sender;
        productSupplyChain[_productID].lastScannedAt = location;
        history[_trackingID].push(
            Transaction(newCustodian, _timestamp, location)
        );

        emit sendTrackingID(_productID);
    }

    /**
     * @return devuelve los detalles de un solo producto dado su trackingID
     */
    function getSingleProduct(string memory _trackingID)
        public
        view
        returns (Product memory)
    {
        require(
            bytes(productSupplyChain[_trackingID].trackingID).length > 0
        ); // comprueba que el producto existe
        return productSupplyChain[_trackingID];
    }

    /**
     * @return indica si quien ejecuta la llamada posee el producto o no
     */
    function scan(string memory _trackingID)
        public
        view
        returns (string memory)
    {
        address productCustodian = productSupplyChain[_trackingID].custodian;
        // comprueba si msg.sender es el propietario actual
        if (productCustodian == msg.sender) {
            return ("owned");
        }
        if (productCustodian != msg.sender && productCustodian != address(0)) {
            return ("unowned");
        } else if (productCustodian == address(0)) {
            return ("new");
        }
    }

    /**
     * @return devuelve la longitud de una lista de transacciones de un objeto con la localización, timestamp de cambio de propietario y el propietario actual
     */
    function getHistoryLength(string memory _trackingID)
        public
        view
        returns (uint256)
    {
        uint256 total = history[_trackingID].length;

        if (total > 0) {
            return total;
        }
    }

    /**
     * @return devuelve una transacción
     */
    function getHistory(uint256 index, string memory _trackingID)
        public
        view
        returns (Transaction memory)
    {
        if (history[_trackingID].length > 0) {
            return (history[_trackingID][index]);
        }
    }
}
