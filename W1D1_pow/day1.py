import hashlib
import time
from Crypto.PublicKey import RSA
from Crypto.Signature import pkcs1_15
from Crypto.Hash import SHA256


def mypow(nickname, difficult):
    nonce = 0
    start_time = time.time()
    while True:
        data = f"{nickname}{nonce}"
        result_hash = hashlib.sha256(data.encode()).hexdigest()
        # print(result)
        if result_hash.startswith('0' * difficult):
            print(f"nonce:{nonce}")
            print(f"result_hash:{result_hash}")
            end_time = time.time()
            print(f"运行时间(秒)：{end_time - start_time}")
            return result_hash
        else:
            nonce += 1


def generate_rsa_keys():
    # 生成私钥
    key = RSA.generate(2048)

    # 导出私钥并保存
    private_key = key.exportKey()
    with open('private_key.pem', 'wb') as f:
        f.write(private_key)

    # 导出公钥并保存
    public_key = key.exportKey()
    with open('public_key.pem', 'wb') as f:
        f.write(public_key)

    return key


if __name__ == '__main__':
    result_hash4 = mypow('shuanglong1104', 4)
    result_hash5 = mypow('shuanglong1104', 5)

    # 获取私钥
    key = generate_rsa_keys()

    # 签名
    hash_value = SHA256.new(result_hash4.encode())
    signature = pkcs1_15.new(key).sign(hash_value)
    print(signature.hex())

    # 验证
    try:
        pkcs1_15.new(key.public_key()).verify(hash_value, signature)
        print("验证成功")
    except:
        print("验证失败")
