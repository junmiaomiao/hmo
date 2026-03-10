// 删除未使用的 router 导入
import http from '@ohos.net.http';

// 1. 定义登录响应接口，消除 any/unknown 警告
interface denglujieguo {
  AccessToken: string;
}

interface dengluxiangying {
  ResultObj: denglujieguo;
}

// 2. 定义传感器数据接口
interface cgqi {
  ApiTag: string;
  Value: string | number;
}

interface shebeijieguo {
  Sensors: cgqi[];
}

interface shebeixiangying {
  ResultObj: shebeijieguo;
}

// 先在文件顶部定义接口
interface LoginPayload {
  Account: string;
  Password: string;
  IsRememberMe: boolean;
}

@Entry
@Component
struct Index {
  @State wendu: string = "XX.XX°C";
  @State shidu: string = "XX%";
  @State lianjie: string = "正常";
  @State isReading: boolean = false;
  @State anniuText: string = "开始读取";
  private timerId: number = -1;
  private api_url: string = "http://api.nlecloud.com";
  private user: string = "13923816248";
  private mima: string = "1234567890";
  private shebeiID: string = "1415409";
  private Token: string = "";

  private async login(): Promise<boolean> {
    const httpqq = http.createHttp();
    const dlu = `${this.api_url}/users/login`;

    const load: LoginPayload = {
      "Account": this.user,
      "Password": this.mima,
      "IsRememberMe": true
    };
    const httptou: Record<string, string> = {};

    const response = await (httpqq.request(
      dlu,
      {
        method: http.RequestMethod.POST,
        header: httptou,
        extraData: JSON.stringify(load)
      }
    ) as Promise<http.HttpResponse>);

    const data = JSON.parse(response.result.toString()) as dengluxiangying;
    this.Token = data.ResultObj?.AccessToken || "";
    httpqq.destroy();
    return this.Token !== "";

  }

  private gethq ():Record<string, string> {
    return{
      "AccessToken":this.Token,
    };
  }

  private async getcgq ():Promise<void>{
    if (!this.Token) {
      await this.login();
    }
    const httpqq = http.createHttp();
    const datau = `${this.api_url}/Devices/${this.shebeiID}`;
    const xy = await (httpqq.request(
      datau,
      {
        method: http.RequestMethod.GET,
        header: this.gethq()
      }
    )as Promise<http.HttpResponse>);

    const data = JSON.parse(xy.result.toString()) as shebeixiangying;
    const cgq = data.ResultObj?.Sensors || [];

    let wd = 0;
    let sd = 0;

    for (const sensor of cgq) {
      const api = sensor.ApiTag;
      const zhi = sensor.Value || 0;

      if (api == "wd") {
        wd = parseFloat(zhi as string);
      } else if (api == "wsd") {
        sd = parseFloat(zhi as string);
      }
    }

    this.wendu = `${wd.toFixed(2)}°C`;
    this.shidu = `${sd.toFixed(2)}%`;
    this.lianjie = "正常";

    httpqq.destroy();
  }

  toggleReading(): void {
    if (!this.isReading) {
      this.isReading = true;
      this.anniuText = "停止";
      this.timerId = setInterval(async () => {
        await this.getcgq();
      }, 1000);
    } else {
      this.isReading = false;
      this.anniuText = "开始读取";
      if (this.timerId !== -1) {
        clearInterval(this.timerId);
        this.timerId = -1;
      }
    }
  }

  build() {
    Column() {
      Text("环境监测系统")
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 30 })

      Text(`室内温度: ${this.wendu}`)
        .fontSize(16)
        .margin({ bottom: 10 })

      Text(`室内湿度: ${this.shidu}`)
        .fontSize(16)
        .margin({ bottom: 20 })

      Text(`连接状态: ${this.lianjie}`)
        .fontSize(14)
        .fontColor("#666666")
        .margin({ bottom: 40 })

      Button(this.anniuText)
        .width(120)
        .height(40)
        .fontSize(16)
        .onClick(() => {
          this.toggleReading();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .padding(20)
  }
}