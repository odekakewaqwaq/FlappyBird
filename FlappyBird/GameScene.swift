//
//  GameScene.swift
//  FlappyBird
//
//  Created by 永井 伸枝 on 2016/04/30.
//  Copyright © 2016年 nobue.nagai. All rights reserved.
//

import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate{
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var appleNode:SKNode!
    var bird:SKSpriteNode!

    //衝突判定カテゴリー
    let birdCategory: UInt32 = 1<<0
    let groundCategory: UInt32 = 1<<1 //ここが何やってるのか正直わからん。１をそのケタ数分ずらすの？もっとたくさんのものが出てきたときは？
    let wallCategory: UInt32 = 1<<2
    let scoreCategory: UInt32 = 1<<3
    let itemScoreCategory: UInt32 = 1<<4
    
    //スコア
    var score = 0
    var itemScore = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var itemScoreLabelNode:SKLabelNode!
    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func didMoveToView(view: SKView){
        
        //重力を設定
        physicsWorld.gravity = CGVector (dx: 0.0, dy: -4.0)
        physicsWorld.contactDelegate = self
        
        //背景色を設定
        backgroundColor = UIColor(colorLiteralRed: 0.15, green:0.75, blue:0.90, alpha: 1)
        
        //スクロールするスプライトの親ノード
        scrollNode = SKNode() /*let追加したけどいいんかな？*/
        addChild(scrollNode)
        
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        appleNode = SKNode()
        scrollNode.addChild(appleNode)
        
        setupGround()
        setupCloud()
        setupWall()
        setupApple()
        setupBird()
        setupScoreLabel()
    
        }
    
 /*------------------------------------------------------------------------------------------------------------*/

    func didBeginContact(contact: SKPhysicsContact) {
        let itemGetSound = SKAction.playSoundFileNamed("itemGet", waitForCompletion: false)
        
        if scrollNode.speed <= 0{
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            print("scoreUp")
            self.score++
            scoreLabelNode.text = "Score:\(score)"
            
            var bestScore = userDefaults.integerForKey("BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.setInteger(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
        }
        else if (contact.bodyA.categoryBitMask & itemScoreCategory) == itemScoreCategory || (contact.bodyB.categoryBitMask & itemScoreCategory) == itemScoreCategory{
            print("getItem")
            self.runAction(itemGetSound)
            self.itemScore++
            itemScoreLabelNode.text = "itemScore:\(itemScore)"
        }
        else{
            //壁か地面と衝突
            print("GameOver")
            
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotateByAngle(CGFloat(M_PI)*CGFloat(bird.position.y), duration: 1)
            bird.runAction(roll, completion: {
                self.bird.speed = 0
            })
        
        }
    }
    
/*------------------------------------------------------------------------------------------------------------*/

    func restart(){
        score = 0
        scoreLabelNode.text = String("Score:\(score)")
        itemScore = 0
        itemScoreLabelNode.text = String("Score:\(score)")
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()
        appleNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    
/*------------------------------------------------------------------------------------------------------------*/
    
    func setupGround(){
    
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        //必要な枚数を計算
        let needNumber = 2.0 + (frame.size.width / groundTexture.size().width)
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveByX(-groundTexture.size().width , y: 0, duration: 5.0)
        
        //元の位置に戻すアクション
        let resetGround = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0.0)
        
        //左にスクロール->元の位置->左にスクロールと無限にくりかえるアクション
        let repeatScrollGround = SKAction.repeatActionForever(SKAction.sequence([moveGround, resetGround]))
        
        //groundのスプライトを配置する
        for var i:CGFloat = 0; i < needNumber; ++i {/*あとでなおしたい*/
            let sprite = SKSpriteNode(texture: groundTexture)
            //スプライトの表示する位置を設定する
            sprite.position = CGPoint(x: i * sprite.size.width, y: groundTexture.size().height / 2)
            //スプライトにアクションを設定する
            sprite.runAction(repeatScrollGround)
            
            //スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: groundTexture.size())
            
            //衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            //衝突の時に動かないように設定する
            sprite.physicsBody?.dynamic = false
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
            
        }
    }
    
 /*------------------------------------------------------------------------------------------------------------*/
    
    func setupCloud(){
        //雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        //必要な枚数を計算
        let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
        
        //スクロールするアクションを作成
        //左方向に画像一枚文スクロールさせるアクション
        let moveCloud = SKAction.moveByX(-cloudTexture.size().width , y:0 , duration: 20.0)
        
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveByX(cloudTexture.size().width , y:0 , duration: 0.0)
        
        //左にスクロール->元の位置->左にスクロールと無限にくりかえるアクション
        let repeatScrollCloud = SKAction.repeatActionForever(SKAction.sequence([moveCloud,resetCloud]))
        
        //スプライトを配置する
        for var i:CGFloat = 0; i < needCloudNumber ; ++i{
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100
            
            sprite.position = CGPoint(x: i * sprite.size.width, y: size.height - cloudTexture.size().height / 2)
            
            sprite.runAction(repeatScrollCloud)
            scrollNode.addChild(sprite)
        }

    }
 /*------------------------------------------------------------------------------------------------------------*/
    
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .Linear
        
        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width * 2)//フレームの幅＋テクスチャ２枚分
        
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveByX(-movingDistance * 2, y: 0, duration:8.0)//4秒かけて移動距離を進む。距離とdurationはりんごと揃える必要がある？
        
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.runBlock({
            // 壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width * 2, y: 0.0)//壁の初期位置、ここを距離分ずらせばいい？
            wall.zPosition = -50.0 // 雲より手前、地面より奥
            
            // 画面のY軸の中央値
            let center_y = self.frame.size.height / 2
            // 壁のY座標を上下ランダムにさせるときの最大値
            let random_y_range = self.frame.size.height / 4
            // 下の壁のY軸の下限
            let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 -  random_y_range / 2)
            // 1〜random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            // キャラが通り抜ける隙間の長さ
            let slit_length = self.frame.size.height / 4
            
            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            wall.addChild(under)
            //下側の壁の物理演算
            under.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size())
            under.physicsBody?.dynamic = false /*なんでオプショナル？*/
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            //上側の壁の物理演算
            upper.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size())
            upper.physicsBody?.dynamic = false
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            //スコアアップ用のノードここから↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0 )
            scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.dynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            //スコアアップ用のノードここまで↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
            
            wall.addChild(upper)
            wall.runAction(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        // 次の壁作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.waitForDuration(2)
        
        // 壁を作成->待ち時間->壁を作成を無限に繰り替えるアクションを作成
        let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        runAction(repeatForeverAnimation)
    }
 /*------------------------------------------------------------------------------------------------------------*/
    
    func setupBird(){
        //鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = SKTextureFilteringMode.Linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = SKTextureFilteringMode.Linear
        
        //2種類のてきすちゃを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animateWithTextures([birdTextureA,birdTextureB], timePerFrame: 0.2)//([birdTextureA,birdTextureB] , timePerFrame: 0.2)
        let flap = SKAction.repeatActionForever(texturesAnimation)
        
        //スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: 30, y:self.frame.size.height * 0.7)
        
        //物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        
        //衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //衝突のカテゴリ設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        //アニメーションを設定
        bird.runAction(flap)
        
        //スプライトを追加する
        addChild(bird)
        
    }
 /*------------------------------------------------------------------------------------------------------------*/
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if scrollNode.speed > 0{
            bird.physicsBody?.velocity = CGVector.zero
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        }else if bird.speed == 0 {
            restart()
        }
    }
    
    func setupScoreLabel(){
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.blackColor()
        scoreLabelNode.position = CGPoint(x: 10,y: self.frame.size.height-30)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.blackColor()
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        let bestScore = userDefaults.integerForKey("BEST")
        bestScoreLabelNode.text = "Best score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        //アイテムスコア表示用
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.blackColor()
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        itemScoreLabelNode.text = "itemScore:\(itemScore)"
        self.addChild(itemScoreLabelNode)
    }
    

 /*------------------------------------------------------------------------------------------------------------*/
func setupApple() {
    // 壁の画像を読み込む
    let appleTexture = SKTexture(imageNamed: "apple")
    appleTexture.filteringMode = .Linear
    
    // 移動する距離を計算
    let movingDistance = CGFloat(self.frame.size.width + appleTexture.size().width * 2)
    
    // 画面外まで移動するアクションを作成
    let moveApple = SKAction.moveByX(-movingDistance * 2, y: 0, duration:8.0)
    
    // 自身を取り除くアクションを作成
    let removeApple = SKAction.removeFromParent()
    
    let appleAnimation = SKAction.sequence([moveApple, removeApple])
    
    // アイテム生成するアクションを作成
    let createAppleAnimation = SKAction.runBlock({
        // アイテムのノードを乗せるノードを作成
        let item = SKNode()
        item.position = CGPoint(x:(self.frame.size.width + appleTexture.size().width * 2) * 1.25, y: 0.0)
        item.zPosition = -50.0 // 雲より手前、地面より奥
        
        // 画面のY軸の中央値
        let center_y = self.frame.size.height / 2
        // 壁のY座標を上下ランダムにさせるときの最大値
        let random_y_range = self.frame.size.height / 4
        // 下の壁のY軸の下限
        let apple_lowest_y = UInt32( center_y - appleTexture.size().height / 2 -  random_y_range / 2)
        // 1〜random_y_rangeまでのランダムな整数を生成
        let random_y = arc4random_uniform( UInt32(random_y_range) )
        // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
        let apple_y = CGFloat(apple_lowest_y + random_y)

        let apple = SKSpriteNode(texture: appleTexture)
        apple.position = CGPoint(x: 0.0, y: apple_y)
        item.addChild(apple)
        
        //アイテムスコア用の設定ここから↓↓↓↓↓↓↓↓↓↓↓↓↓
        let itemScoreNode = SKNode()
        itemScoreNode.position = apple.position
        itemScoreNode.physicsBody = SKPhysicsBody(circleOfRadius: appleTexture.size().height / 2)
        itemScoreNode.physicsBody?.dynamic = false
        itemScoreNode.physicsBody?.categoryBitMask = self.itemScoreCategory
        itemScoreNode.physicsBody?.contactTestBitMask = self.birdCategory
        
        item.addChild(itemScoreNode)
        //アイテムスコア用の設定ここまで↑↑↑↑↑↑↑↑↑↑↑↑↑
        
        item.runAction(appleAnimation)
        self.appleNode.addChild(item)
    })
    
    // 次の壁作成までの待ち時間のアクションを作成
    let waitAnimation = SKAction.waitForDuration(2)
    
    // 壁を作成->待ち時間->壁を作成を無限に繰り替えるアクションを作成
    let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence([createAppleAnimation, waitAnimation]))
    
    runAction(repeatForeverAnimation)
}

}














