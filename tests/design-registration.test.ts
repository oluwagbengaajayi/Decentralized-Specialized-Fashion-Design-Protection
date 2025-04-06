import { describe, it, expect, beforeEach } from 'vitest';

// Mock contract implementation
const designRegistrationContract = {
  lastDesignId: 0,
  designs: {},
  
  getLastDesignId() {
    return this.lastDesignId;
  },
  
  getDesign(designId) {
    return this.designs[designId] || null;
  },
  
  registerDesign(sender, name, description, imageUri) {
    const newDesignId = this.lastDesignId + 1;
    this.designs[newDesignId] = {
      owner: sender,
      name,
      description,
      imageUri,
      createdAt: 10, // Mock block height
      status: 'active'
    };
    this.lastDesignId = newDesignId;
    return { success: true, value: newDesignId };
  },
  
  updateDesignStatus(sender, designId, newStatus) {
    const design = this.designs[designId];
    if (!design) {
      return { success: false, error: 1 };
    }
    if (design.owner !== sender) {
      return { success: false, error: 3 };
    }
    this.designs[designId].status = newStatus;
    return { success: true, value: true };
  }
};

describe('Design Registration Contract', () => {
  beforeEach(() => {
    // Reset contract state
    designRegistrationContract.lastDesignId = 0;
    designRegistrationContract.designs = {};
  });
  
  it('should register a new design', () => {
    const sender = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
    const result = designRegistrationContract.registerDesign(
        sender,
        'Summer Collection Dress',
        'A floral pattern summer dress with open back',
        'ipfs://QmXyZ123456789'
    );
    
    expect(result.success).toBe(true);
    expect(result.value).toBe(1);
    expect(designRegistrationContract.lastDesignId).toBe(1);
    
    const design = designRegistrationContract.getDesign(1);
    expect(design).not.toBeNull();
    expect(design.owner).toBe(sender);
    expect(design.name).toBe('Summer Collection Dress');
    expect(design.status).toBe('active');
  });
  
  it('should update design status', () => {
    const sender = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
    designRegistrationContract.registerDesign(
        sender,
        'Winter Jacket',
        'Waterproof winter jacket with fur hood',
        'ipfs://QmAbc123456789'
    );
    
    const result = designRegistrationContract.updateDesignStatus(
        sender,
        1,
        'inactive'
    );
    
    expect(result.success).toBe(true);
    expect(designRegistrationContract.getDesign(1).status).toBe('inactive');
  });
  
  it('should not allow non-owners to update design status', () => {
    const owner = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
    const nonOwner = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
    
    designRegistrationContract.registerDesign(
        owner,
        'Leather Handbag',
        'Handcrafted leather handbag with gold accents',
        'ipfs://QmDef123456789'
    );
    
    const result = designRegistrationContract.updateDesignStatus(
        nonOwner,
        1,
        'inactive'
    );
    
    expect(result.success).toBe(false);
    expect(result.error).toBe(3);
    expect(designRegistrationContract.getDesign(1).status).toBe('active');
  });
});
