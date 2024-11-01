package main

import (
	"context"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/openziti/sdk-golang/ziti"
	"github.com/sirupsen/logrus"
)

var zitiContext ziti.Context

func createZitifiedHttpClient(idFile string) *http.Client {
	cfg, err := ziti.NewConfigFromFile(idFile)
	if err != nil {
		panic(err)
	}

	cfg.ConfigTypes = append(cfg.ConfigTypes, ziti.InterceptV1)
	zitiContext, err = ziti.NewContext(cfg)
	if err != nil {
		panic(err)
	}

	zitiContexts := ziti.NewSdkCollection()
	zitiContexts.Add(zitiContext)
	err = zitiContext.Authenticate()
	if err != nil {
		panic(err)
	}
	zitiTransport := http.DefaultTransport.(*http.Transport).Clone()
	zitiTransport.DialContext = func(ctx context.Context, network, addr string) (net.Conn, error) {
		dialer := zitiContexts.NewDialer()
		return dialer.Dial(network, addr)
	}

	return &http.Client{Transport: zitiTransport}
}

type ZitiDialContext struct {
	context ziti.Context
}

func (dc *ZitiDialContext) Dial(_ context.Context, _ string, addr string) (net.Conn, error) {
	service := strings.Split(addr, ":")[0] // will always get passed host:port
	return dc.context.Dial(service)
}

func createZitifiedHttpClientServiceName(idFile string) *http.Client {
	cfg, err := ziti.NewConfigFromFile(idFile)
	if err != nil {
		panic(err)
	}

	cfg.ConfigTypes = append(cfg.ConfigTypes, ziti.InterceptV1)
	zitiContext, err = ziti.NewContext(cfg)
	if err != nil {
		panic(err)
	}

	zitiDialContext := ZitiDialContext{context: zitiContext}

	zitiTransport := http.DefaultTransport.(*http.Transport).Clone() // copy default transport
	zitiTransport.DialContext = zitiDialContext.Dial
	zitiTransport.TLSClientConfig.InsecureSkipVerify = true
	return &http.Client{Transport: zitiTransport}
}

func main() {
	logrus.SetLevel(logrus.DebugLevel)
	httpClient := createZitifiedHttpClient(os.Args[1])
	time.Sleep(5 * time.Second)
	resp, e := httpClient.Get(os.Args[2])
	if e != nil {
		panic(e)
	}
	body, _ := io.ReadAll(resp.Body)
	fmt.Println(string(body))

	httpClientByService := createZitifiedHttpClientServiceName(os.Args[1])
	time.Sleep(5 * time.Second)
	respByService, e := httpClientByService.Get("http://sample")
	if e != nil {
		panic(e)
	}
	bodyByService, _ := io.ReadAll(respByService.Body)
	fmt.Println(string(bodyByService))
}
