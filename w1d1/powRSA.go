package main

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/hex"
	"encoding/pem"
	"fmt"
	"log"
	"time"
)

// POW 结构体包含 POW 计算所需的基本信息
type POW struct {
	nickname string        // 用户昵称
	nonce    int           // 随机数
	hash     string        // 计算得到的哈希值
	duration time.Duration // 计算耗时
	data     string        // 原始数据(昵称+nonce)
}

// NewPOW 创建一个新的 POW 实例
func NewPOW(nickname string) *POW {
	return &POW{
		nickname: nickname,
		nonce:    0,
	}
}

// Compute 计算满足指定难度(前导零个数)的哈希
func (p *POW) Compute(leadingZeros int) {
	start := time.Now()

	for {
		p.data = fmt.Sprintf("%s%d", p.nickname, p.nonce)
		hash := sha256.Sum256([]byte(p.data))
		hashStr := hex.EncodeToString(hash[:])

		// 检查是否满足前导零条件
		if hasLeadingZeros(hashStr, leadingZeros) {
			p.hash = hashStr
			p.duration = time.Since(start)
			break
		}

		p.nonce++
	}
}

// hasLeadingZeros 检查哈希字符串是否以指定数量的0开头
func hasLeadingZeros(hash string, zeros int) bool {
	if zeros <= 0 {
		return true
	}
	if zeros > len(hash) {
		return false
	}
	for _, c := range hash[:zeros] {
		if c != '0' {
			return false
		}
	}
	return true
}

// PrintResult 打印计算结果
func (p *POW) PrintResult(leadingZeros int) {
	fmt.Printf("找到 %d 个前导零的哈希:\n", leadingZeros)
	fmt.Printf("输入内容: %s\n", p.data)
	fmt.Printf("哈希值: %s\n", p.hash)
	fmt.Printf("耗时: %v\n", p.duration)
	fmt.Println("----------------------------------")
}

// RSAKeyPair 封装RSA密钥对相关操作
type RSAKeyPair struct {
	privateKey *rsa.PrivateKey
	publicKey  *rsa.PublicKey
}

// GenerateKeyPair 生成RSA密钥对
func (k *RSAKeyPair) GenerateKeyPair(bits int) error {
	privateKey, err := rsa.GenerateKey(rand.Reader, bits)
	if err != nil {
		return err
	}
	k.privateKey = privateKey
	k.publicKey = &privateKey.PublicKey
	return nil
}

// SignData 使用私钥签名数据
func (k *RSAKeyPair) SignData(data []byte) ([]byte, error) {
	hashed := sha256.Sum256(data)
	signature, err := rsa.SignPKCS1v15(rand.Reader, k.privateKey, crypto.SHA256, hashed[:])
	if err != nil {
		return nil, err
	}
	return signature, nil
}

// VerifySignature 使用公钥验证签名
func (k *RSAKeyPair) VerifySignature(data []byte, signature []byte) error {
	hashed := sha256.Sum256(data)
	return rsa.VerifyPKCS1v15(k.publicKey, crypto.SHA256, hashed[:], signature)
}

// PrintPublicKey 打印公钥信息
func (k *RSAKeyPair) PrintPublicKey() {
	publicKeyBytes, err := x509.MarshalPKIXPublicKey(k.publicKey)
	if err != nil {
		log.Printf("Error marshaling public key: %v", err)
		return
	}
	publicKeyPem := pem.EncodeToMemory(&pem.Block{
		Type:  "RSA PUBLIC KEY",
		Bytes: publicKeyBytes,
	})
	fmt.Println("公钥信息:")
	fmt.Println(string(publicKeyPem))
}

func main() {
	// 1. 执行POW计算
	nickname := "DeepSeek"
	pow := NewPOW(nickname)
	pow.Compute(4)
	pow.PrintResult(4)

	// 2. 生成RSA密钥对
	keyPair := &RSAKeyPair{}
	err := keyPair.GenerateKeyPair(2048)
	if err != nil {
		log.Fatalf("生成密钥对失败: %v", err)
	}
	keyPair.PrintPublicKey()

	// 3. 使用私钥签名
	signature, err := keyPair.SignData([]byte(pow.data))
	if err != nil {
		log.Fatalf("签名失败: %v", err)
	}
	fmt.Printf("签名结果(hex): %x\n", signature)

	// 4. 使用公钥验证
	err = keyPair.VerifySignature([]byte(pow.data), signature)
	if err != nil {
		log.Fatalf("验证签名失败: %v", err)
	}
	fmt.Println("签名验证成功!")
}
