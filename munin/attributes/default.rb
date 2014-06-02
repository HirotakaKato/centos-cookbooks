# 監視対象の設定
default['munin'] = [
  {
    node: 'localhost',
    directives: [
      'address 127.0.0.1',
      'use_node_name yes',
      'load.load.warning 2',
    ],
  },
]
