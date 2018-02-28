import cp = require('child_process');
import fs = require('fs');
const filePath = process.env.QUICKLOCK_FILEPATH;
const grandParentPid = process.env.QUICKLOCK_GRANDPARENT_PID;

if (!filePath) {
  throw new Error('Quicklock error - missing filepath.');
}

if (!grandParentPid) {
  throw new Error('Quicklock error - missing grandParentPid.');
}

process.once('exit', function () {
  fs.unlinkSync(filePath);
});

// setInterval(function () {
//   try {
//     cp.execSync(`ps -p ${grandParentPid}`)
//   }
//   catch (err) {
//     try {
//       fs.unlinkSync(filePath);
//     }
//     finally {
//       process.exit(0);
//     }
//   }
// }, 500);

const k = cp.spawn(`wait`, [grandParentPid]);

k.once('exit', function () {
  try {
    fs.unlinkSync(filePath);
  }
  finally {
    process.exit(0);
  }
});

console.log('quicklock child listening.');