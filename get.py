#coding=utf-8

import click
import requests
from lxml import etree

@click.command()
@click.option('--suffix', help='url suffix')
def main(suffix):
    url = 'https://pastebin.ubuntu.com/p/' + suffix + '/'
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36'
    }
    try:
        response = requests.get(url=url, headers=headers)
        tree = etree.HTML(response.text)
        code = tree.xpath('//*[@id="hidden-content"]')[0]
        res = code.text.replace('\r', '')
        print(res)
    except Exception as e:
        print('None')

if __name__ == '__main__':
    main()
