require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-etherscan');


module.exports = {

  'etherscan': {
    // ApiKey: "T2CYHZ1WWB2ZUGTRR42THGTB718FJXPK88"
    'apiKey': 'VTJJ86VD6ZKVE3WQBMRE1CGP7HUM4Z8KRC', // Testnet Binance

  },
  'mocha': {
    'timeout': 20000,
  },
  'networks': {
    'hardhat': {},
    // 0x1454fB0FAa18195d50818a590f912a940A5f03AA
    // 065006b3a500142836de1346435a79885e9c3a1751b36fd65bca788525968989
    'bsc': {
      'accounts': ['a4f96c04ed56df73a0f1b36bcdac8b479f75d08459817435e3b2b95c8d49724c'],
      'url': 'https://data-seed-prebsc-1-s1.binance.org:8545',
    },
  },
  'paths': {
    'sources': './contracts',
    'artifacts': './artifacts',
    'cache': './cache',
    'tests': './test',
  },
  'solidity': {
    'compilers': [
      {
        'version': '0.8.0',
      },
      {
        'version': '0.8.7',
      },
      {
        'version': '0.7.3',
      },
      {
        'version': '0.5.16',
      },
    ],
    'settings': {
      'optimizer': {
        'enabled': true,
        'runs': 200,
      },
    },
  },
  'watcher': {
    'ci': {
      'tasks': [
        'clean',
        {'command': 'compile',
          'params': {'quiet': true}},
        {
          'command': 'test',
          'params': {'noCompile': true,
            'testFiles': ['testfile.ts']},
        },
      ],
    },
    'compilation': {
      'tasks': ['compile'],
      'files': ['./contracts'],
      'verbose': true,
    },
  },
};