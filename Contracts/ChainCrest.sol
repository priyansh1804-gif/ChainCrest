Structure to represent a credential/achievement
    struct Credential {
        uint256 id;
        address issuer;
        address recipient;
        string credentialType;
        string credentialHash; State variables
    uint256 private credentialCounter;
    mapping(uint256 => Credential) public credentials;
    mapping(address => uint256[]) public recipientCredentials;
    mapping(address => bool) public authorizedIssuers;
    address public admin;
    
    Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier onlyAuthorizedIssuer() {
        require(authorizedIssuers[msg.sender], "Not an authorized issuer");
        _;
    }
    
    constructor() {
        admin = msg.sender;
        authorizedIssuers[msg.sender] = true;
        credentialCounter = 0;
    }
    
    /**
     * @dev Issue a new credential to a recipient
     * @param _recipient Address of the credential recipient
     * @param _credentialType Type of credential (e.g., "Degree", "Certificate", "Badge")
     * @param _credentialHash IPFS hash or reference to credential data
     * @return credentialId The ID of the newly issued credential
     */
    function issueCredential(
        address _recipient,
        string memory _credentialType,
        string memory _credentialHash
    ) public onlyAuthorizedIssuer returns (uint256) {
        require(_recipient != address(0), "Invalid recipient address");
        require(bytes(_credentialType).length > 0, "Credential type required");
        require(bytes(_credentialHash).length > 0, "Credential hash required");
        
        credentialCounter++;
        uint256 newCredentialId = credentialCounter;
        
        credentials[newCredentialId] = Credential({
            id: newCredentialId,
            issuer: msg.sender,
            recipient: _recipient,
            credentialType: _credentialType,
            credentialHash: _credentialHash,
            issuedDate: block.timestamp,
            isValid: true
        });
        
        recipientCredentials[_recipient].push(newCredentialId);
        
        emit CredentialIssued(
            newCredentialId,
            msg.sender,
            _recipient,
            _credentialType,
            block.timestamp
        );
        
        return newCredentialId;
    }
    
    /**
     * @dev Verify if a credential is valid
     * @param _credentialId ID of the credential to verify
     * @return isValid Boolean indicating if the credential is valid
     * @return issuer Address of the issuer
     * @return recipient Address of the recipient
     * @return credentialType Type of the credential
     */
    function verifyCredential(uint256 _credentialId) 
        public 
        view 
        returns (
            bool isValid,
            address issuer,
            address recipient,
            string memory credentialType
        ) 
    {
        require(_credentialId > 0 && _credentialId <= credentialCounter, "Invalid credential ID");
        
        Credential memory cred = credentials[_credentialId];
        
        return (
            cred.isValid,
            cred.issuer,
            cred.recipient,
            cred.credentialType
        );
    }
    
    /**
     * @dev Revoke a credential (only by the original issuer)
     * @param _credentialId ID of the credential to revoke
     */
    function revokeCredential(uint256 _credentialId) public {
        require(_credentialId > 0 && _credentialId <= credentialCounter, "Invalid credential ID");
        Credential storage cred = credentials[_credentialId];
        require(cred.issuer == msg.sender, "Only issuer can revoke");
        require(cred.isValid, "Credential already revoked");
        
        cred.isValid = false;
        
        emit CredentialRevoked(_credentialId, msg.sender);
    }
    
    update
update
// 
// 
update
// 
